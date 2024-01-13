from __future__ import annotations

import json
import time
from dataclasses import dataclass
from threading import Thread

import pyric.pyw  # noqa: F401
from pyric.utils import rfkill
from pyroute2 import IW, IPRoute, netlink

RT_TABLE_MAIN: int = 254


UNIT_MULTIPLIER = 1024
UNIT_PREFIXES = ["", "k", "M", "G", "T"]


def fixed_width(number: float, width: int) -> str:
    int_part = int(number)
    int_len = len(str(int_part))
    if int_len >= width:
        return str(round(number))
    elif int_len + 1 == width:
        # WARNING: this is NOT a space, it's a nobreak space, because a normal space is not large enough
        return " " + str(round(number))
    else:
        return f"{number:.{width - (int_len + 1)}f}"


def format_bytes(quantity: float) -> str:
    i = 0
    while quantity > 1000:
        quantity /= UNIT_MULTIPLIER
        i += 1

    prefix = UNIT_PREFIXES[i]
    return f"{fixed_width(quantity, 4 - len(prefix))}{prefix}B"


@dataclass
class Route:
    index: int
    priority: int = 0
    iname: str = ""
    address: str | None = None  # mainly used to know if we're only linked and not connected
    state: str = "DOWN"

    # Speed
    rx_bytes: int = 0
    tx_bytes: int = 0
    last_update: int = 0
    rx_speed: int = 0
    tx_speed: int = 0

    # Wifi only
    ssid: str | None = None
    signal_strength: int | None = None


class NetState:
    def __init__(self: NetState) -> None:
        self.default_route: Route | None = None

    def run(self: NetState) -> None:
        with IPRoute() as ipr, IW() as iw:
            self.ipr = ipr
            self.iw = iw
            self.ipr.bind()

            self.default_route = self.get_default_route()
            Thread(target=self.mainloop, daemon=True).start()

            while True:
                for _ in ipr.get():
                    # tbh I don't want to parse events to update infos, we juste re-read everything from scratch
                    new_route = self.get_default_route()
                    if new_route is None:
                        self.default_route = None
                    elif self.default_route is None:
                        self.default_route = new_route
                    elif new_route.index != self.default_route.index:
                        self.default_route = new_route
                        self.wifi_strength()
                        self.updated()

    def mainloop(self: NetState) -> None:
        while True:
            self.wifi_strength()

            if self.default_route:
                rx, tx = self.get_bytes()
                now = time.time()
                delta_time = now - self.default_route.last_update
                self.default_route.rx_speed, self.default_route.tx_speed = (
                    (rx - self.default_route.rx_bytes) / delta_time,
                    (tx - self.default_route.tx_bytes) / delta_time,
                )
                self.default_route.rx_bytes, self.default_route.tx_bytes = rx, tx
                self.default_route.last_update = now

            self.updated()
            time.sleep(1)

    def get_default_route(self: NetState) -> Route | None:
        candidates = []

        for route in self.ipr.get_default_routes():
            if route["table"] != RT_TABLE_MAIN:
                continue

            attrs = dict(route["attrs"])
            if "RTA_GATEWAY" not in attrs:
                continue

            if "RTA_DST" in attrs:
                continue

            index = attrs["RTA_OIF"]
            priority = attrs["RTA_PRIORITY"]
            candidates.append((index, priority))

        if not candidates:
            return None

        index, priority = sorted(candidates, key=lambda x: x[1], reverse=True)[0]
        route_ = Route(index, priority)

        addr = next(filter(lambda x: x["index"] == index, self.ipr.get_addr()), None)
        if not addr:
            return route_

        attrs = dict(addr["attrs"])
        route_.iname = attrs["IFA_LABEL"]
        route_.address = attrs.get("IFA_ADDRESS", None)

        link = next(filter(lambda x: x["index"] == index, self.ipr.get_links()), None)
        if not link:
            return route_

        attrs = dict(link["attrs"])
        route_.state = attrs["IFLA_OPERSTATE"]

        (interface,) = self.iw.get_interface_by_ifindex(route_.index)
        if not interface:
            return route_

        attrs = dict(interface["attrs"])

        if "NL80211_ATTR_SSID" not in attrs:
            return route_
        route_.ssid = attrs["NL80211_ATTR_SSID"]

        return route_

    def wifi_strength(self: NetState) -> None:
        if not self.default_route:
            return

        try:
            data = self.iw.get_associated_bss(self.default_route.index)
        except netlink.exceptions.NetlinkDumpInterrupted:
            self.wifi_strength()

        if not data:
            return

        attrs = dict(dict(data["attrs"])["NL80211_ATTR_BSS"]["attrs"])
        signal = attrs["NL80211_BSS_SIGNAL_MBM"]["SIGNAL_STRENGTH"]
        strength, unit = signal["VALUE"], signal["UNITS"]

        if unit != "dBm":
            msg = f"Unknown wifi strength unit: {unit}"
            raise ValueError(msg)

        # I stole the homeworks of Waybar

        # WiFi-hardware usually operates in the range -90 to -30dBm.
        # If a signal is too strong, it can overwhelm receiving circuity that is designed
        # to pick up and process a certain signal level. The following percentage is scaled to
        # punish signals that are too strong (>= -45dBm) or too weak (<= -45 dBm).
        hardware_optimum = -45
        hardware_min = -90
        strength = 100 - ((abs(strength - hardware_optimum) / (hardware_optimum - hardware_min)) * 100)
        strength = max(0, min(strength, 100))

        self.default_route.signal_strength = int(strength)
        self.default_route.ssid = attrs["NL80211_BSS_INFORMATION_ELEMENTS"]["SSID"].decode()

    def get_bytes(self: NetState) -> tuple[int, int]:
        if self.default_route is None:
            return 0, 0

        link = next(filter(lambda x: x["index"] == self.default_route.index, self.ipr.get_links()), None)
        if not link:
            return 0, 0

        attrs = dict(link["attrs"])
        return attrs["IFLA_STATS64"]["rx_bytes"], attrs["IFLA_STATS64"]["tx_bytes"]

    def updated(self: NetState) -> None:
        connected = False
        if self.default_route is None:
            wkill = next(dev for dev in rfkill.rfkill_list().values() if dev["type"] == "wlan")
            if wkill["soft"] or wkill["hard"]:
                icon = "󰖪"
                tooltip = "Wifi: Disabled\nEthernet: Not detected"
            else:
                icon = "󰤯"
                tooltip = "Wifi: Disconnected\nEthernet: Not detected"
        elif self.default_route.state == "DOWN":
            icon = "󰤯"
            tooltip = "Wifi: Disconnected\nEthernet: Not detected"
        elif self.default_route.address is None:
            icon = "󱚵"
            tooltip = "Wifi: Linked"
            connected = True
        elif self.default_route.ssid:
            if self.default_route.signal_strength:
                icon = ["󰤟", "󰤢", "󰤥", "󰤨"][int(self.default_route.signal_strength / 25.1)]
            else:
                icon = "󱛇"
            tooltip = f"Wifi: {self.default_route.ssid}\n{self.default_route.iname}: {self.default_route.address}"
            connected = True
        else:
            icon = "󰈁"
            tooltip = f"{self.default_route.iname}: {self.default_route.address}"
            connected = True

        if connected:
            speeds = (
                f"  {format_bytes(self.default_route.tx_speed)}/s    {format_bytes(self.default_route.rx_speed)}/s"
            )
        else:
            speeds = ""

        print(json.dumps({"icon": icon, "tooltip": tooltip, "speeds": speeds}), flush=True)


def main() -> None:
    n = NetState()
    n.run()


if __name__ == "__main__":
    main()
