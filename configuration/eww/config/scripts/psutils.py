from __future__ import annotations

import json
import time
from dataclasses import dataclass
from typing import NamedTuple

import psutil


class Temperature(NamedTuple):
    label: str
    current: float
    high: float
    critical: float


class PsutilVirtualMemory(NamedTuple):
    total: int
    available: int
    percent: float
    used: int
    free: int
    active: int
    inactive: int
    buffers: int
    cached: int
    shared: int
    slab: int


class PsutilSwapMemory(NamedTuple):
    total: int
    used: int
    free: int
    percent: float
    sin: int
    sout: int


@dataclass(frozen=True)
class Memory:
    total: int
    used: int
    cache: int
    swap: int


def get_class(temp: Temperature) -> str:
    if temp.current > temp.critical:
        return "critical"
    elif temp.current > temp.high:
        return "high"
    else:
        return ""


UNIT_MULTIPLIER = 1024
UNIT_PREFIXES = ["", "k", "M", "G", "T"]


def fixed_width(number: float, width: int) -> str:
    int_part = int(number)
    int_len = len(str(int_part))
    if int_len >= width:
        return str(round(number))
    elif int_len + 1 == width:
        return " " + str(round(number))
    else:
        return f"{number:.{width - (int_len + 1)}f}"


def format_bytes(quantity: float) -> str:
    i = 0
    while quantity > 1000:
        quantity /= UNIT_MULTIPLIER
        i += 1

    return f"{fixed_width(quantity, 3)}{UNIT_PREFIXES[i]}B"


def get_mem(mem: PsutilVirtualMemory, swap: PsutilSwapMemory) -> Memory:
    return Memory(
        total=mem.total,
        used=(mem.total - mem.free) - (mem.buffers + mem.cached),
        cache=mem.buffers + mem.cached,
        swap=swap.used,
    )


while True:
    temps: dict[str, list[Temperature]] = psutil.sensors_temperatures()
    disk_temp = temps["nvme"][0]
    cpu_temp = temps["acpitz"][0]

    mem = get_mem(psutil.virtual_memory(), psutil.swap_memory())
    memp = round((mem.used / mem.total) * 100)
    memclass = ""
    if memp > 90:
        memclass = "critical"
    elif memp > 70:
        memclass = "warning"

    cpu: int = round(psutil.cpu_percent())
    cpuclass = ""
    if cpu > 90:
        cpuclass = "critical"
    elif cpu > 70:
        cpuclass = "warning"

    print(
        json.dumps(
            {
                "temperatures": {
                    "cpu": {"value": round(cpu_temp.current), "class": get_class(cpu_temp)},
                    "nvme": {"value": round(disk_temp.current), "class": get_class(disk_temp)},
                },
                "memory": {
                    "class": memclass,
                    "usedp": memp,
                    "used": format_bytes(mem.used),
                    "cache": format_bytes(mem.cache),
                    "swap": format_bytes(mem.swap),
                },
                "cpu": {
                    "class": cpuclass,
                    "percent": cpu,
                    "freq": f"{psutil.cpu_freq().current / 1000:.2f}",
                    "tooltip": "\n".join(
                        f"Core {i:2}: {round(p):3}%" for i, p in enumerate(psutil.cpu_percent(percpu=True))
                    ),
                },
            },
        ),
        flush=True,
    )
    time.sleep(1)
