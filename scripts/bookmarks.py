#!/usr/bin/python
import csv
import subprocess
import sys
import webbrowser
from pathlib import Path
from typing import cast

BOOKMARKS_FILE = Path.home() / "documents/org/bookmarks.csv"


def main() -> int:
    with BOOKMARKS_FILE.open(newline="") as file:
        reader = csv.DictReader(file, strict=True)
        data = list(reader)
        input_data: str = "".join(
            f"{row['type']} - {row['name']} ({row['link']})\n" for row in data
        )

    if not data:
        return 1

    for row in data:
        row["count"] = int(row.get("count") or 0)

    try:
        result = subprocess.check_output(
            ["rofi", "-dmenu", "-i", "-format", "i"], text=True, input=input_data
        ).strip()
        if not result:
            return 1
    except subprocess.CalledProcessError:
        return 1

    bookmark = data[int(result)]
    _ = webbrowser.open(cast(str, bookmark["link"]))

    bookmark["count"] = cast(int, bookmark["count"]) + 1

    data.sort(key=lambda x: x["count"], reverse=True)

    with BOOKMARKS_FILE.open("w", newline="") as file:
        writer = csv.DictWriter(
            file, strict=True, fieldnames=["type", "name", "link", "count"]
        )
        writer.writeheader()
        writer.writerows(data)

    return 0


if __name__ == "__main__":
    sys.exit(main())
