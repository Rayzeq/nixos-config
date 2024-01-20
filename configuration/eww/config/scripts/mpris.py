from __future__ import annotations

import json
from datetime import timedelta
from typing import TYPE_CHECKING

import pydbus

if TYPE_CHECKING:
    from typing_extensions import Self


class UnsupportedOperation(Exception):
    """Raised when calling an MPRIS operation the player does not support."""


class MprisService:
    """Class representing an MPRIS2 compatible media player."""

    mpris_base = "org.mpris.MediaPlayer2"
    player_interface = mpris_base + ".Player"
    tracklist_interface = mpris_base + ".TrackList"
    playlists_interface = mpris_base + ".Playlists"
    # see http://dbus.freedesktop.org/doc/dbus-specification.html#standard-interfaces-properties
    properties_interface = "org.freedesktop.DBus.Properties"

    def __init__(self: Self, servicename: str) -> None:
        """Initialize an MprisService object for the specified service name."""
        bus = pydbus.SessionBus()
        self.name = servicename.removeprefix(self.mpris_base + ".")
        self._name = servicename
        self._proxy = bus.get(self._name, "/org/mpris/MediaPlayer2")
        self.base = self._proxy[self.mpris_base]
        self.player = self._proxy[self.player_interface]
        self.properties = self._proxy[self.properties_interface]
        # tracklist is an optional interface
        try:
            self.tracklist = self._proxy[self.tracklist_interface]
        except KeyError:
            self.tracklist = None
        # playlists is an optional interface
        try:
            self.playlists = self._proxy[self.playlists_interface]
        except KeyError:
            self.playlists = None

    @property
    def status(self: Self) -> str:
        return self.player.PlaybackStatus

    @property
    def position(self: Self) -> timedelta | None:
        try:
            return timedelta(microseconds=self.player.Position)
        except Exception:
            return None

    @property
    def length(self: Self) -> timedelta | None:
        length = self.player.Metadata.get("mpris:length")
        if length:
            return timedelta(microseconds=length)
        else:
            return None

    @property
    def title(self: Self) -> str | None:
        return self.player.Metadata.get("xesam:title")

    @property
    def album(self: Self) -> str | None:
        return self.player.Metadata.get("xesam:album")

    @property
    def url(self: Self) -> str | None:
        return self.player.Metadata.get("xesam:url")

    @property
    def art_url(self: Self) -> str | None:
        return self.player.Metadata.get("mpris:artUrl")

    @property
    def artists(self: Self) -> list[str] | None:
        artists = self.player.Metadata.get("xesam:artist")
        if artists is None:
            return None

        artists = list(filter(bool, artists))
        if artists:
            return artists
        else:
            return None

    def base_properties(self: Self):
        """Get all basic service properties"""
        return self.properties.GetAll(self.mpris_base)

    def player_properties(self: Self):
        """Get all player properties"""
        return self.properties.GetAll(self.player_interface)

    def _assert_control(self: Self):
        if not self.player.CanControl:
            raise UnsupportedOperation(f"{self._name} does not provide control access")

    def open(self: Self, uri) -> None:
        """Open media from URI and start playback"""
        try:
            self.player.OpenUri(uri)
        except AttributeError as ex:
            raise UnsupportedOperation(f"{self._name} does not support opening URIs") from ex

    def next(self: Self) -> None:
        """Play next track."""
        self._assert_control()
        if not self.player.CanGoNext:
            msg = f"{self._name} does not support switching to next track"
            raise UnsupportedOperation(msg)
        self.player.Next()

    def previous(self: Self) -> None:
        """Play previous track."""
        self._assert_control()
        if not self.player.CanGoPrevious:
            msg = f"{self._name} does not support switching to previous track"
            raise UnsupportedOperation(msg)
        self.player.Previous()

    def pause(self: Self) -> None:
        """Pause playback."""
        self._assert_control()
        if not self.player.CanPause:
            msg = f"{self._name} does not support pausing"
            raise UnsupportedOperation(msg)
        self.player.Pause()

    def play(self: Self) -> None:
        """Start playback."""
        self._assert_control()
        if not self.player.CanPlay:
            msg = f"{self._name} does not support playing"
            raise UnsupportedOperation(msg)
        self.player.Play()

    def stop(self: Self) -> None:
        """Stop playback."""
        self._assert_control()
        self.player.Stop()

    def toggle(self: Self) -> None:
        """Toggle play/pause state."""
        self._assert_control()
        if not self.player.CanPause:
            msg = f"{self._name} does not support pausing"
            raise UnsupportedOperation(msg)
        self.player.PlayPause()


def get_services() -> list[str]:
    """Get the list of available MPRIS2 services."""
    bus = pydbus.SessionBus()
    return [service for service in bus.get(".DBus").ListNames() if service.startswith(MprisService.mpris_base)]


def get_pid(service: str) -> int:
    """Get the PID of the process that owns the specified service."""
    bus = pydbus.SessionBus()
    return bus.get(".DBus").GetConnectionUnixProcessID(service)


def main() -> None:
    services = [service for service in get_services() if "playerctld" not in service]
    services_formated = []

    for s in services:
        service = MprisService(s)

        progress = service.position * 100 / service.length if service.position and service.length else None
        if service.position:
            seconds = service.position.seconds
            minutes, seconds = divmod(seconds, 60)
            hours, minutes = divmod(minutes, 60)
            position = f"{hours}:{minutes:02d}:{seconds:02d}" if hours > 0 else f"{minutes}:{seconds:02d}"
        else:
            position = "???"
        if service.length:
            seconds = service.length.seconds
            minutes, seconds = divmod(seconds, 60)
            hours, minutes = divmod(minutes, 60)
            length = f"{hours}:{minutes:02d}:{seconds:02d}" if hours > 0 else f"{minutes}:{seconds:02d}"
        else:
            length = "???"
        properties = service.player_properties()
        services_formated.append(
            {
                "pid": get_pid(s),
                "id": service.name,
                "can_toggle": service.player.CanControl and service.player.CanPlay and service.player.CanPause,
                "can_go_previous": service.player.CanControl and properties.get("CanGoPrevious", False),
                "can_go_next": service.player.CanControl and properties.get("CanGoNext", False),
                "status": "󰏤" if service.status == "Playing" else "󰐊",
                "title": service.title,
                "artists": " + ".join(service.artists or []) or "Unknown",
                "album": service.album or "",
                "art": (service.art_url or "").removeprefix("file://") or "./assets/music.png",
                "progress": progress or -1,
                "position": position,
                "length": length,
            },
        )

    print(json.dumps(services_formated), flush=True)


if __name__ == "__main__":
    main()
