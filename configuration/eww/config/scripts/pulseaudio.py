from __future__ import annotations

import json
from dataclasses import dataclass

import pulsectl


@dataclass
class SinkSourceInfo:
    # The internal name
    name: str = ""
    # The display name
    desc: str = ""
    volume: int = 0
    muted: bool = False

    # Only used by the sink

    # Whether it's being used
    running: bool = False
    form_factor: str = ""
    port_name: str = ""


class Pulseinfo:
    def __init__(self: Pulseinfo) -> None:
        self.event: pulsectl.PulseEventInfo | None = None
        self.sink = SinkSourceInfo()
        self.source = SinkSourceInfo()

    def run(self: Pulseinfo) -> None:
        with pulsectl.Pulse("eww-statusbar") as pulse:
            self.pulse = pulse
            self.parse_server_info()
            self.updated()

            pulse.event_mask_set(
                pulsectl.PulseEventMaskEnum.server,
                pulsectl.PulseEventMaskEnum.sink,
                pulsectl.PulseEventMaskEnum.sink_input,
                pulsectl.PulseEventMaskEnum.source,
                pulsectl.PulseEventMaskEnum.source_output,
            )
            pulse.event_callback_set(self.handle_events)

            while True:
                pulse.event_listen()

                # the loop has been stopped, that means we got an event
                if self.event is not None:
                    if self.event.facility == pulsectl.PulseEventFacilityEnum.server:
                        self.parse_server_info()
                    elif self.event.facility == pulsectl.PulseEventFacilityEnum.sink:
                        # pa_context_get_sink_info_by_index has no binding so we do it manually

                        for sink_info in self.pulse.sink_list():
                            if sink_info.index == self.event.index:
                                self.parse_sink_info(sink_info)
                    elif self.event.facility == pulsectl.PulseEventFacilityEnum.sink_input:
                        for sink_info in self.pulse.sink_list():
                            self.parse_sink_info(sink_info)
                    elif self.event.facility == pulsectl.PulseEventFacilityEnum.source:
                        for source_info in self.pulse.source_list():
                            if source_info.index == self.event.index:
                                self.parse_source_info(source_info)
                    elif self.event.facility == pulsectl.PulseEventFacilityEnum.source_output:
                        for source_info in self.pulse.source_list():
                            self.parse_source_info(source_info)

                    self.event = None
                    self.updated()

    def handle_events(self: Pulseinfo, event: pulsectl.PulseEventInfo) -> None:
        if event.t != pulsectl.PulseEventTypeEnum.change:
            return

        # can't use any pulsectl methods here, so we save the event and stop the event loop
        self.event = event
        raise pulsectl.PulseLoopStop

    def parse_server_info(self: Pulseinfo) -> None:
        info = self.pulse.server_info()

        if self.sink.name != info.default_sink_name:
            self.sink = SinkSourceInfo(name=info.default_sink_name)
        if self.source.name != info.default_source_name:
            self.source = SinkSourceInfo(name=info.default_source_name)

        for sink_info in self.pulse.sink_list():
            self.parse_sink_info(sink_info)
        for source_info in self.pulse.source_list():
            self.parse_source_info(source_info)

    def parse_sink_info(self: Pulseinfo, info: pulsectl.PulseSinkInfo) -> None:
        if self.sink.name == info.name:
            self.sink.running = info.state == pulsectl.PulseStateEnum.running

        if not self.sink.running and info.state == pulsectl.PulseStateEnum.running:
            self.sink = SinkSourceInfo(name=info.name, running=True)

        if self.sink.name == info.name:
            self.sink.volume = round(info.volume.value_flat * 100)
            self.sink.muted = info.mute != 0
            self.sink.desc = info.description
            self.sink.form_factor = info.proplist.get("device.form_factor", "")
            if info.port_active:
                self.sink.port_name = info.port_active.name

    def parse_source_info(self: Pulseinfo, info: pulsectl.PulseSourceInfo) -> None:
        if self.source.name == info.name:
            self.source.volume = round(info.volume.value_flat * 100)
            self.source.muted = info.mute != 0
            self.source.desc = info.description

    @staticmethod
    def is_bluetooth(sink_source: SinkSourceInfo) -> bool:
        return (
            "a2dp_sink" in sink_source.name  # PulseAudio
            or "a2dp-sink" in sink_source.name  # PipeWire
            or "bluez" in sink_source.name
        )

    def updated(self: Pulseinfo) -> None:
        fullname = self.sink.port_name + " " + self.sink.form_factor
        sink_class = "output"
        if "headphone" in fullname:
            icon = "󰋋"
        elif "speaker" in fullname:
            icon = "󰕾"
        elif "headset" in fullname:
            icon = "󰋎"
        else:
            icon = "󰕾"

        if self.is_bluetooth(self.sink):
            sink_class += " bluetooth"
            icon = "󰂯 " + icon

        sink_fmt = f"{icon}  {self.sink.volume}%"

        if self.sink.muted:
            sink_class += " muted"
            sink_fmt = "󰖁"

        source_class = "input"
        icon = ""
        if self.is_bluetooth(self.source):
            source_class += " bluetooth"
            icon = "󰂯 " + icon

        source_fmt = f"{icon}  {self.source.volume}%"

        if self.source.muted:
            source_class += " muted"
            source_fmt = ""

        print(
            json.dumps(
                {
                    "sink": {"format": sink_fmt, "name": self.sink.desc, "class": sink_class},
                    "source": {"format": source_fmt, "name": self.source.desc, "class": source_class},
                },
            ),
            flush=True,
        )


def main() -> None:
    p = Pulseinfo()
    p.run()


if __name__ == "__main__":
    main()
