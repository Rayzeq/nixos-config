pragma Singleton

import QtQuick
import Quickshell

Scope {
    property bool light: Application.styleHints.colorScheme === Qt.ColorScheme.Light

    property color window: light ? Qt.rgba(0.95, 0.95, 0.95, 0.6) : Qt.rgba(0.1, 0.1, 0.1, 0.6)

    property color cardBg: light ? Qt.rgba(1, 1, 1, 0.8) : Qt.rgba(0.15, 0.15, 0.15, 0.8)
    property color cardSecondaryBg: light ? Qt.rgba(0.9, 0.9, 0.9, 0.9) : Qt.rgba(0.1, 0.1, 0.1, 0.9)
    property color cardHover: light ? Qt.rgba(1, 1, 1, 1.0) : Qt.rgba(0.2, 0.2, 0.2, 1.0)
    property color cardBorder: light ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)

    property color buttonBackground: light ? Qt.rgba(0.8, 0.8, 0.8, 0.8) : Qt.rgba(0.3, 0.3, 0.3, 0.8)
    property color buttonBackgroundHover: light ? Qt.rgba(0.9, 0.9, 0.9, 0.8) : Qt.rgba(0.4, 0.4, 0.4, 0.8)

    property color textPrimary: light ? "#2e3436" : "#eeeeec"
    property color textSecondary: light ? "#888a85" : "#babdb6"
}
