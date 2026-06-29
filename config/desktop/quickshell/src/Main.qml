pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

import "components"

Scope {
    Lockscreen {
        id: lockscreen

        onSecureChanged: {
            if (lockscreen.secure) {
                ipc.lockSecure();
            }
        }
    }

    Clipboard {
        id: clipboard
        visible: false

        Shortcut {
            sequences: [StandardKey.Cancel]
            onActivated: clipboard.visible = false
        }
    }

    IpcHandler {
        id: ipc
        target: "shell"

        signal lockSecure

        function lock() {
            lockscreen.locked = true;
        }

        function openClipboard() {
            clipboard.visible = true;
        }
    }
}
