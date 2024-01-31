from __future__ import annotations

import html
import json
import os
import re
import socket as sockmod
import subprocess
import sys
from typing import Any, Generator


def call(command: str) -> Any:
    return json.loads(subprocess.run(["hyprctl", "-j", command], capture_output=True, check=True).stdout)


def events() -> Generator[tuple[str, str], None, None]:
    sock = sockmod.socket(sockmod.AF_UNIX, sockmod.SOCK_STREAM)
    sock.connect(f"/tmp/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock")
    socket = sock.makefile()

    while True:
        event = socket.readline().strip()
        name, value = event.split(">>")
        yield name, value

    socket.close()
    sock.close()


SYMBOLS = {
    0: "〇",
    1: "一",
    2: "二",
    3: "三",
    4: "四",
    5: "五",
    6: "六",
    7: "七",
    8: "八",
    9: "九",
    10: "十",
    100: "百",
    1_000: "千",
    10_000: "万",
    100_000_000: "億",
    1_000_000_000_000: "兆",
    10_000_000_000_000_000: "京",
}


def translate(number: int) -> str:
    if number in SYMBOLS:
        return SYMBOLS[number]
    else:
        nstr = str(number)
        current = int(nstr[0] + "0" * len(nstr[1:]))
        result = ""
        for number, symbol in reversed(SYMBOLS.items()):
            if number == current:
                result += symbol
                break
            if number < current:
                result += translate(current // number)
                result += symbol
                break

        remaining = int(nstr[1:])
        if remaining == 0:
            return result
        else:
            return result + translate(int(nstr[1:]))


REWRITES = {
    # this will apply to youtube inside firefox
    re.compile(r"(.*) - YouTube"): r"󰗃  \1",
    re.compile(r"(.*) — Mozilla Firefox Private Browsing"): r'<span foreground="#b13dff">󰈹</span>  \1',
    re.compile(r"(.*) — Mozilla Firefox"): r"󰈹  \1",
    # remove space between icons
    re.compile(r"(󰈹|>)  (󰗃)"): r"\1 \2",
    re.compile(r"(.*) - Sublime Text \(.*\)"): r"  \1",
    re.compile(r"• Discord \| (.*)"): r"󰙯  \1",
}


def format_window(title: str) -> str:
    title = html.escape(title)

    for pattern, replacement in REWRITES.items():
        title = pattern.sub(replacement, title)

    return title


def print_data(workspaces: list[str], active_workspace: str, active_window: str) -> None:
    print(
        json.dumps(
            {
                "workspaces": [
                    {"id": workspace, "name": translate(int(workspace)), "active": workspace == active_workspace}
                    for workspace in workspaces
                ],
                "window": format_window(active_window),
            },
        ),
        flush=True,
    )


result = call("workspaces")
workspaces = [
    workspace["name"] for workspace in result if workspace["name"] != "special" and workspace["monitor"] == sys.argv[1]
]
result = call("activeworkspace")
active_workspace = result["name"]
result = call("activewindow")
active_window = result.get("title", "")

workspaces.sort(key=int)
print_data(workspaces, active_workspace, active_window)

for name, value in events():
    updated = True
    if name == "workspace":
        active_workspace = value
    elif name == "createworkspace":
        workspaces.append(value)
    elif name == "destroyworkspace":
        workspaces.remove(value)
    elif name == "activewindow":
        class_, title = value.split(",", maxsplit=1)
        active_window = title
    else:
        updated = False

    if updated:
        workspaces.sort(key=int)
        print_data(workspaces, active_workspace, active_window)
