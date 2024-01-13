import json
import sys
import time
from pathlib import Path

BAT_PATH = Path("/sys/class/power_supply/BAT0")

while True:
    status = (BAT_PATH / "status").read_text().strip()
    capacity = int((BAT_PATH / "capacity").read_text())
    energy_full = int((BAT_PATH / "energy_full").read_text())
    energy_full_design = int((BAT_PATH / "energy_full_design").read_text())

    remaining_energy = int((BAT_PATH / "energy_now").read_text()) / 1000
    # present_rate is 0 for some seconds after the AC has been plugged
    present_rate = int((BAT_PATH / "power_now").read_text()) / 1000
    last_capacity_unit = energy_full / 1000
    voltage = int((BAT_PATH / "voltage_now").read_text()) / 1000

    remaining_capacity = remaining_energy * 1000 / voltage
    present_rate = present_rate * 1000 / voltage
    last_capacity = last_capacity_unit * 1000 / voltage

    if status == "Discharging":
        icon = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][round(capacity / 10)]
        class_ = "discharging"
        seconds = (3600 * remaining_capacity / present_rate) if present_rate > 0 else 0
    elif status == "Charging":
        icon = "󰂄"
        class_ = "charging"
        seconds = (3600 * (last_capacity - remaining_capacity) / present_rate) if present_rate > 0 else 0
    elif status == "Full":
        icon = ""
        class_ = "full"
        seconds = 0
    elif status == "Not charging":
        icon = ""
        class_ = "not-charging"
        seconds = 0
    else:
        print(f"Unknown status: {status}", file=sys.stderr)
        icon = "?"
        class_ = ""
        seconds = 0

    if capacity <= 5:
        class_ += " critical"
    elif capacity <= 15:
        class_ += " warning"

    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    seconds, minutes, hours = round(seconds), int(minutes), int(hours)

    print(
        json.dumps(
            {
                "icon": icon,
                "class": class_,
                "capacity": capacity,
                "health": round(energy_full * 100 / energy_full_design),
                "time_to": f"{hours}h {minutes}min",
            },
        ),
        flush=True
    )
    time.sleep(2)
