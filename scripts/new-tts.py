#!/usr/bin/python
import pyperclip
import subprocess

def main():
    input = pyperclip.paste()
    subprocess.run(["piper"])

    
    print(input)

if __name__ == "__main__":
    main()
