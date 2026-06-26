#!/bin/python
import json
import os
from pathlib import Path
import subprocess
from tempfile import NamedTemporaryFile, _TemporaryFileWrapper  # pyright: ignore[reportPrivateUsage]
import time
from typing import Any
import urllib
import requests
import pyperclip
import threading
import signal

PID_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "tts-jp.pid"

mpv: subprocess.Popen[Any] | None = None  # pyright: ignore[reportExplicitAny]
finish = threading.Event()
end = threading.Event()
files: list[_TemporaryFileWrapper[bytes]] = []


def play_audio(file_path: Path):
    global mpv
    mpv = subprocess.Popen(
        ["mpv", "--script=/usr/lib/mpv-mpris/mpris.so", "--no-config", str(file_path)]
    )
    _ = mpv.wait()


def play_lines():
    while not finish.is_set() or files:
        if files:
            file = files.pop(0)
            path = Path(file.name)
            try:
                if not end.is_set():
                    play_audio(path)
                    time.sleep(0.5)
            finally:
                path.unlink()
        else:
            time.sleep(1)


def get_wav_from_text(text: str) -> bytes:
    speaker_index = 2
    audio_query_response = requests.post(
        "http://127.0.0.1:50021/audio_query?speaker="  # pyright: ignore[reportUnknownArgumentType]
        + str(speaker_index)
        + "&text="
        + urllib.parse.quote(text, safe="")  # pyright: ignore[reportUnknownMemberType, reportAttributeAccessIssue]
    )
    assert audio_query_response.status_code == 200
    audio_query = audio_query_response.json()  # pyright: ignore[reportAny]
    audio_query["speedScale"] = 0.6
    audio_query_json = json.dumps(audio_query)

    synthesis_response = requests.post(
        "http://127.0.0.1:50021/synthesis?speaker=" + str(speaker_index),
        data=audio_query_json,
    )
    assert synthesis_response.status_code == 200
    return synthesis_response.content


def handler(_signum: int, _):
    print(mpv)
    if mpv:
        mpv.kill()
    end.set()


_ = signal.signal(signal.SIGINT, handler)  # pyright: ignore[reportUnknownArgumentType]
_ = signal.signal(signal.SIGTERM, handler)  # pyright: ignore[reportUnknownArgumentType]

if __name__ == "__main__":
    if PID_FILE.exists():
        pid = int(PID_FILE.read_text())
        try:
            os.kill(pid, signal.SIGINT)
            time.sleep(2)
        except ProcessLookupError:
            PID_FILE.unlink()

    _ = PID_FILE.write_text(str(os.getpid()))

    lines = pyperclip.paste().split("。")
    lines.insert(0, "START")
    t = threading.Thread(target=play_lines, args=())

    t.start()

    for line in lines:
        line = line.strip()
        if not line:
            continue
        f = NamedTemporaryFile(delete=False, suffix=".wav")
        _ = Path(f.name).write_bytes(get_wav_from_text(line))
        files.append(f)
        f.close()
        if end.is_set():
            break

    finish.set()

    t.join()
    PID_FILE.unlink()
