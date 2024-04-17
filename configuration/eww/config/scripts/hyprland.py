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
        try:
            name, value = event.split(">>", maxsplit=1)
        except ValueErr:
            print("TOO MANY SPLIT", event, file=sys.stderr)
            exit()
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


def print_data(workspaces: list[str], active_workspace: str, active_window: str, special_active: bool) -> None:
    print(
        json.dumps(
            {
                "workspaces": [
                    {"id": w, "name": "零" if w == "special" else translate(int(w)), "active": (w == active_workspace) or (w == "special" and special_active)}
                    for w in workspaces
                ],
                "window": format_window(active_window),
            },
        ),
        flush=True,
    )


result = call("workspaces")
workspaces = [
    workspace["name"] for workspace in result if workspace["monitor"] == sys.argv[1]
]
result = call("activeworkspace")
active_workspace = result["name"]
result = call("activewindow")
active_window = result.get("title", "")
special_active = False

workspaces.sort(key=lambda x: -1 if x == "special" else int(x))
print_data(workspaces, active_workspace, active_window, special_active)

for name, value in events():
    updated = True
    if name == "workspace":
        active_workspace = value
    elif name == "createworkspace":
        workspaces.append(value)
    elif name == "destroyworkspace":
        workspaces.remove(value)
    elif name == "activespecial":
        name, monitor = value.split(",")
        if name == '':
            special_active = False
        else:
            special_active = True
    elif name == "activewindow":
        class_, title = value.split(",", maxsplit=1)
        active_window = title
    elif name == "openwindow":
        _, _, _, title = value.split(",", maxsplit=3)
        if title == "Update - Sublime Text":
            # capture_output=True to prevent hyprctl from printing things
            subprocess.run(["hyprctl", "dispatch", "closewindow", f"title:^{title}$"], capture_output=True)
    else:
        updated = False

    if updated:
        workspaces.sort(key=lambda x: -1 if x == "special" else int(x))
        print_data(workspaces, active_workspace, active_window, special_active)
