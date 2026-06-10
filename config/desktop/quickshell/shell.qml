pragma ComponentBehavior: Bound

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

    IpcHandler {
        id: ipc
        target: "shell"

        signal lockSecure

        function lock() {
            lockscreen.locked = true;
        }
    }
}
