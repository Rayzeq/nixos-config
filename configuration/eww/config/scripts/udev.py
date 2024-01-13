import pyudev


def print_brightness(device: pyudev.Device) -> None:
    actual_brightness = device.attributes.asint("actual_brightness")
    max_brightness = device.attributes.asint("max_brightness")
    print(round(actual_brightness * 100 / max_brightness), flush=True)


context = pyudev.Context()
monitor = pyudev.Monitor.from_netlink(context, "udev")
monitor.filter_by("backlight")

print_brightness(next(iter(context.list_devices(subsystem="backlight"))))

for device in iter(monitor.poll, None):
    print_brightness(device)
