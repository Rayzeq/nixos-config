import QtQuick
import Quickshell

ShellRoot {
    FloatingWindow {
        Lockscreen {
            anchors.fill: parent

            onUnlocked: Qt.quit()
        }
    }

    Connections {
        target: Quickshell

        function onLastWindowClosed() {
            Qt.quit();
        }
    }
}
