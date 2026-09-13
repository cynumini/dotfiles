#!/usr/bin/python

import queue
import re
import json
import threading
import signal
import tempfile
import time
import urllib
import pyperclip
import subprocess
import requests
from pathlib import Path
from typing import Protocol
from enum import Enum, auto

import unicodedata

CLI_MAX_TEXT = 512


class Config:
    piper_model: Path = (
        Path.home() / ".local/share/piper-tts/en_US-hfc_female-medium.onnx"
    )


class File(Protocol):
    name: str

    def close(self) -> None: ...


def play(filename: Path):
    proc = subprocess.run(
        [
            "mpv",
            "--no-config",
            f"--script={Path.home()}/opt/mpv-mpris/mpris.so",
            filename,
        ]
    )
    if proc.returncode != 0:
        raise RuntimeError(f"Couldn't play {filename}")


def play_thread(files: queue.Queue[File]):
    while True:
        try:
            file = files.get()
            try:
                filename = Path(file.name)
                try:
                    play(filename)
                finally:
                    file.close()
                    filename.unlink()
            finally:
                files.task_done()
        except queue.ShutDown:
            break


def add_to_queue(files: queue.Queue[File], sentence: str, language: Language):
    response = do_request(sentence, language)
    file: File = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    assert file.write(response.content) == len(response.content)
    file.close()
    files.put(file)


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
            Config.piper_model,
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


class Language(Enum):
    ENGLISH = auto()
    JAPANESE = auto()
    NEUTRAL = auto()


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


def main():
    files: queue.Queue[File] = queue.Queue(maxsize=0)

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

    # response: requests.Response | None = None

    servers = []
    print(japanese_count, english_count, neutral_count, mode)
    t = threading.Thread(target=play_thread, args=(files,))
    t.start()
    if mode == Mode.CLI:
        # TODO: use play thread
        file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
        file.close()
        filename = Path(file.name)
        try:
            proc = subprocess.run(
                [
                    "piper",
                    "-m",
                    Config.piper_model,
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
    elif mode == Mode.ENGLISH_ONLY or mode == Mode.JAPANESE_ONLY:
        sentences: list[str] = []
        sep = r""
        if mode == Mode.ENGLISH_ONLY:
            servers.append(start_piper_server())
            sep = r"\. |\n"
        else:
            servers.append(start_voicevox_server())
            sep = r"。"

        sentences: list[str] = re.split(sep, text)

        for sentence in sentences:
            if not sentence:
                continue
            elif len(sentence) == 1 and get_char_language(sentence) == Language.NEUTRAL:
                continue

            language = (
                Language.ENGLISH
                if mode  == Mode.ENGLISH_ONLY
                else Language.JAPANESE
            )

            add_to_queue(files, sentence, language)
    else:
        servers.append(start_piper_server())
        servers.append(start_voicevox_server())

        chars = list(text)
        sentence_language = Language.NEUTRAL
        sentence = ""

        sentences: list[tuple[str, Language]] = []

        while chars:
            char = chars.pop(0)

            language = get_char_language(char)

            if sentence_language == language:
                sentence += char
            elif sentence_language == Language.NEUTRAL or language == Language.NEUTRAL:
                sentence += char
                if sentence_language == Language.NEUTRAL:
                    sentence_language = language
            else:
                sentences.append((sentence.strip(), sentence_language))
                sentence = char
                sentence_language = language

        sentences.append((sentence.strip(), sentence_language))

        # print(sentences)

        for sentence in sentences:
            # TODO: actually I need split this sentence in subsentence
            add_to_queue(files, sentence[0], sentence[1])

    files.shutdown()

    files.join()
    t.join()

    for server in servers:
        server.send_signal(signal.SIGINT)
        _ = server.wait()
    # TODO: new instance kill previous


if __name__ == "__main__":
    main()
