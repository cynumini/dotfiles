#!/usr/bin/python

import json
import pyperclip
import queue
import re
import requests
import signal
import socket
import subprocess
import sys
import tempfile
import threading
import time
import unicodedata
import urllib

from enum import Enum, auto
from pathlib import Path
from typing import Protocol

stop_event = threading.Event()

CLI_MAX_TEXT: int = 512
PIPER_MODEL: Path = Path.home() / ".local/share/piper-tts/en_US-hfc_female-medium.onnx"
SOCKET: Path = Path("/tmp/tts.sock")


class File(Protocol):
    name: str

    def close(self) -> None: ...


def play(filename: Path):
    cmd = [
        "mpv",
        "--no-config",
        f"--script={Path.home()}/opt/mpv-mpris/mpris.so",
        filename,
    ]
    with subprocess.Popen(cmd) as mpv:
        while mpv.poll() is None:
            if stop_event.wait(0.1):
                mpv.terminate()
                break


def play_thread(files: queue.Queue[File]):
    while True:
        try:
            file = files.get()
        except queue.ShutDown:
            break
        filename = Path(file.name)
        try:
            play(filename)
        finally:
            file.close()
            filename.unlink(missing_ok=True)
            files.task_done()


class Language(Enum):
    ENGLISH = auto()
    JAPANESE = auto()
    NEUTRAL = auto()


def add_to_queue(files: queue.Queue[File], sentence: str, language: Language):
    response = do_request(sentence, language)
    file: File = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    assert file.write(response.content) == len(response.content)
    file.close()
    try:
        files.put(file)
    except queue.ShutDown:
        pass


class Mode(Enum):
    CLI = auto()  # piper only with cli
    ENGLISH_ONLY = auto()  # piper server
    ENGLISH_JAPANESE = auto()  # piper + VOICEVOX server
    JAPANESE_ONLY = auto()  # VOICEVOX sever


def start_piper_server():
    return subprocess.Popen(
        [
            Path.home() / "opt/venv11/bin/python",
            "-m",
            "piper.http_server",
            "-m",
            PIPER_MODEL,
        ]
    )


def start_voicevox_server():
    return subprocess.Popen([Path.home() / "opt/vv-engine/run"])


def piper_request(sentence: str):
    for i in range(3):
        try:
            response = requests.post(
                "http://127.0.0.1:5000/synthesize",
                json={"text": sentence},
            )
            return response
        except requests.exceptions.ConnectionError:
            print("Wait!")
            time.sleep(1)
    raise RuntimeError("Piper connection error")


def voicevox_request(sentence: str):
    for i in range(3):
        try:
            speaker_index = 2
            audio_query_response = requests.post(
                "http://127.0.0.1:50021/audio_query?speaker="  # pyright: ignore[reportUnknownArgumentType]
                + str(speaker_index)
                + "&text="
                + urllib.parse.quote(sentence, safe="")  # pyright: ignore[reportUnknownMemberType, reportAttributeAccessIssue]
            )
            assert audio_query_response.status_code == 200
            audio_query = audio_query_response.json()  # pyright: ignore[reportAny]
            audio_query["speedScale"] = 0.6
            audio_query_json = json.dumps(audio_query)

            response = requests.post(
                "http://127.0.0.1:50021/synthesis?speaker=" + str(speaker_index),
                data=audio_query_json,
            )
            return response
        except requests.exceptions.ConnectionError:
            print("Wait!")
            time.sleep(1)
    raise RuntimeError("Piper connection error")


def do_request(sentence: str, language: Language):
    assert language != Language.NEUTRAL
    if language == Language.ENGLISH:
        return piper_request(sentence)
    return voicevox_request(sentence)


def get_char_language(char: str) -> Language:
    japanese_names = [
        "CJK",
        "HIRAGANA",
        "KATAKANA",
    ]

    name = unicodedata.name(char, "UNKNOWN")

    for prefix in japanese_names:
        if name.startswith(prefix):
            return Language.JAPANESE
    if name.startswith("LATIN"):
        return Language.ENGLISH
    return Language.NEUTRAL


def process_text(files: queue.Queue[File], block: tuple[str, Language]):
    text, language = block
    if language == Language.ENGLISH:
        sep = r"\.\s+|\n+"
    else:
        sep = r"。|！|？"
    sentences: list[str] = re.split(sep, text)
    for sentence in sentences:
        if not sentence:
            continue
        elif len(sentence) == 1 and get_char_language(sentence) == Language.NEUTRAL:
            continue
        add_to_queue(files, sentence, language)


def listen(files: queue.Queue[File]):
    SOCKET.unlink(missing_ok=True)
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.settimeout(1.0)
    server.bind(str(SOCKET))
    server.listen(1)
    while not stop_event.is_set():
        print("server start")
        try:
            connection, _ = server.accept()
            connection.close()
            stop_event.set()
            files.shutdown(immediate=True)
            print("server end")
        except socket.timeout:
            pass
        print("timeout")


def main():
    files: queue.Queue[File] = queue.Queue(maxsize=0)
    servers = []
    try:
        try:
            connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            connection.connect(str(SOCKET))
            connection.close()
            time.sleep(2)
        except FileNotFoundError:
            pass
        except ConnectionRefusedError:
            SOCKET.unlink(missing_ok=True)
        server_thread = threading.Thread(target=listen, daemon=True, args=(files,))
        server_thread.start()

        text: str = pyperclip.paste()

        japanese_count = 0
        english_count = 0
        neutral_count = 0

        for c in text:
            match get_char_language(c):
                case Language.JAPANESE:
                    japanese_count += 1
                case Language.ENGLISH:
                    english_count += 1
                case Language.NEUTRAL:
                    neutral_count += 1

        mode = Mode.CLI

        if japanese_count > english_count:
            mode = Mode.JAPANESE_ONLY
        elif japanese_count > 0:
            mode = Mode.ENGLISH_JAPANESE
        elif len(text) > CLI_MAX_TEXT:
            mode = Mode.ENGLISH_ONLY

        if mode == Mode.CLI:
            file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
            filename = Path(file.name)
            file.close()
            try:
                proc = subprocess.run(
                    [
                        "piper",
                        "-m",
                        PIPER_MODEL,
                        "-f",
                        filename,
                    ],
                    input=text,
                    text=True,
                )
                assert proc.returncode == 0
                play(filename)
            finally:
                filename.unlink()
            return 0

        print(japanese_count, english_count, neutral_count, mode)
        t = threading.Thread(target=play_thread, args=(files,))
        t.start()
        if mode == Mode.ENGLISH_ONLY or mode == Mode.JAPANESE_ONLY:
            if mode == Mode.ENGLISH_ONLY:
                servers.append(start_piper_server())
                process_text(files, (text, Language.ENGLISH))
            else:
                servers.append(start_voicevox_server())
                process_text(files, (text, Language.JAPANESE))
                print("-" * 10, 13)
        else:
            servers.append(start_piper_server())
            servers.append(start_voicevox_server())

            sentence_language = Language.NEUTRAL
            block_text: str = ""

            blocks: list[tuple[str, Language]] = []

            for char in text:
                language = get_char_language(char)

                if sentence_language == language:
                    block_text += char

                elif sentence_language == Language.NEUTRAL:
                    block_text += char
                    sentence_language = language

                elif language == Language.NEUTRAL:
                    block_text += char

                else:
                    blocks.append((block_text.strip(), sentence_language))
                    block_text = char
                    sentence_language = language

            if block_text.strip():
                blocks.append((block_text.strip(), sentence_language))

            for block in blocks:
                print(block)
                process_text(files, block)

        files.shutdown()
        files.join()
        t.join()

        return 0
    finally:
        for server in servers:
            if server.poll() is None:
                server.send_signal(signal.SIGINT)
                server.wait()


if __name__ == "__main__":
    sys.exit(main())
