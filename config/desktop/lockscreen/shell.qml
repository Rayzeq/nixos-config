pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland

ShellRoot {
    WlSessionLock {
        id: lock

        locked: true

        WlSessionLockSurface {
            Lockscreen {
                anchors.fill: parent

                onUnlocked: {
                    lock.locked = false;
                    Qt.quit();
                }
            }
        }
    }
}
