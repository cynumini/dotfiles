#!/usr/bin/python
import signal
import tempfile
import pyperclip
import subprocess
import requests
from pathlib import Path


def main():
    server_cmd = [
        Path.home() / "opt/venv11/bin/python",
        "-m",
        "piper.http_server",
        "-m",
        Path.home() / ".local/share/piper-tts/en_US-hfc_female-medium.onnx",
    ]
    server = subprocess.Popen(server_cmd)

    text = pyperclip.paste()

    sentences = text.split()

    while True:
        try:
            response = requests.post(
                "http://127.0.0.1:5000/synthesize",
                json={"text": text},
            )
            break
        except requests.exceptions.ConnectionError:
            pass

        print("you are slow")

    file = tempfile.NamedTemporaryFile(delete=False, suffix = ".wav")
    filename = Path(file.name);
    _ = filename.write_bytes(response.content)

    _ = subprocess.run(["mpv", "-no-config", filename])

    file.close()
    filename.unlink()

    server.send_signal(signal.SIGINT)
    _ = server.wait()


if __name__ == "__main__":
    main()
