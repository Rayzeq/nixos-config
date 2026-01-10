#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash

# TODO: replace with `config.rofi.command.clipboard` when in fullmanager
selection=$(cliphist list | rofi -dmenu -display-columns 2 -p "Clipboard" -theme "~/.config/rofi/clipboard.rasi")
if [ ! -z "$selection" ]; then
	printf "$selection" | cliphist decode | wl-copy
fi