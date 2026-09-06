#!/usr/bin/python
import os
import threading
import signal
import tempfile
import time
import pyperclip
import subprocess
import requests
from pathlib import Path
from typing import Protocol
from enum import Enum, auto

import unicodedata

CLI_MAX_TEXT = 512

# running = True


# class File(Protocol):
#     name: str

#     def close(self) -> None: ...


# files: list[File] = []


# def mpv():
#     global running, files
#     while running or files:
#         if files:
#             file = files.pop(0)
#             filename = Path(file.name)
#             _ = subprocess.run(["mpv", "-no-config", filename])
#             file.close()
#             filename.unlink()


class Mode(Enum):
    CLI = auto()  # piper only with cli
    ENGLISH_ONLY = auto()  # piper server
    ENGLISH_JAPANESE = auto()  # piper + VOICEVOX server
    JAPANESE_ONLY = auto()  # VOICEVOX sever


def main():
    text = pyperclip.paste()

    japanese_count = 0
    english_count = 0
    neutral_count = 0

    for c in text:
        japanese_names = [
            "CJK",
            "HIRAGANA",
            "KATAKANA",
        ]
        english_names = ["LATIN"]

        checked = False
        name = unicodedata.name(c, "UNKNOWN")
        for prefix in japanese_names:
            if name.startswith(prefix):
                japanese_count += 1
                checked = True
        for prefix in english_names:
            if name.startswith(prefix):
                english_count += 1
                checked = True
        if not checked:
            neutral_count += 1
            checked = True

    mode = Mode.CLI

    if japanese_count > english_count:
        mode = Mode.JAPANESE_ONLY
    elif japanese_count > 0:
        mode = Mode.ENGLISH_JAPANESE
    elif len(text) > CLI_MAX_TEXT:
        mode = Mode.ENGLISH_ONLY

    match mode:
        case Mode.CLI:
            file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
            file.close()
            filename = Path(file.name)
            try:
                proc = subprocess.run(
                    [
                        "piper",
                        "-m",
                        Path.home()
                        / ".local/share/piper-tts/en_US-hfc_female-medium.onnx",
                        "-f",
                        filename,
                    ],
                    input=text,
                    text=True,
                )
                assert proc.returncode == 0
                proc = subprocess.run(
                    [
                        "mpv",
                        "--no-config",
                        f"--script={Path.home()}/opt/mpv-mpris/mpris.so",
                        filename,
                    ]
                )
                assert proc.returncode == 0
            finally:
                filename.unlink()
        case _:
            print(japanese_count, english_count, neutral_count)
            os.abort()

    # TODO: Mode.ENGLISH_ONLY
    # TODO: Mode.JAPANESE_ONLY
    # TODO: Mode.ENGLISH_JAPANESE


def server():
    # TODO: if the text is too short and doesn't contain Japanese
    # characters, then run without a server

    # TODO: add a Japanese server and use only it if the text is 95% Japanese
    # TODO: allow mixing Japanese and English text

    global running, files

    server_cmd = [
        Path.home() / "opt/venv11/bin/python",
        "-m",
        "piper.http_server",
        "-m",
        Path.home() / ".local/share/piper-tts/en_US-hfc_female-medium.onnx",
    ]
    server = subprocess.Popen(server_cmd)

    sentences = text.split(".")

    mpv_thread = threading.Thread(target=mpv)
    mpv_thread.start()

    for sentence in sentences:
        if not sentence:
            continue

        response: requests.Response | None = None
        for i in range(3):
            try:
                response = requests.post(
                    "http://127.0.0.1:5000/synthesize",
                    json={"text": sentence},
                )

                break
            except requests.exceptions.ConnectionError:
                print("Wait!")
                time.sleep(1)

        if not response:
            running = False
            mpv_thread.join()
            assert response

        file: File = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
        _ = Path(file.name).write_bytes(response.content)
        files.append(file)
        print(f'Add "{sentence}"')

    print(running)
    running = False
    print(running)

    mpv_thread.join()

    server.send_signal(signal.SIGINT)
    _ = server.wait()


if __name__ == "__main__":
    main()
