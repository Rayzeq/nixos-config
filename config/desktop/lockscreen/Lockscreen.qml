pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Item {
    id: root
    anchors.fill: parent
    focus: true

    property string password: ""
    property bool capslock: false
    property bool numlock: false
    property double size: this.height * (16 / 9) < this.width ? this.width : this.height * (16 / 9)
    property bool isUnlocking: false

    signal keypress
    signal backspace
    signal cleared
    signal tryUnlock
    signal unlockFailed
    signal unlocked

    PamContext {
        id: pam

        config: "quickshell"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.password);
            }
        }

        onCompleted: result => {
            root.password = "";
            root.isUnlocking = false;
            if (result == PamResult.Success) {
                root.unlocked();
            } else {
                root.unlockFailed();
            }
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "cat /sys/class/leds/*::capslock/brightness 2>/dev/null | grep -q 1 && echo true || echo false"]
        stdout: StdioCollector {
            onStreamFinished: root.capslock = this.text.trim() == "true"
        }
    }
    Process {
        running: true
        command: ["sh", "-c", "cat /sys/class/leds/*::numlock/brightness 2>/dev/null | grep -q 1 && echo true || echo false"]
        stdout: StdioCollector {
            onStreamFinished: root.numlock = this.text.trim() == "true"
        }
    }
    Keys.onPressed: event => {
        if (isUnlocking) {
            return;
        }

        if (event.key === Qt.Key_Escape || (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier))) {
            this.password = "";
            this.cleared();

            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            this.isUnlocking = true;
            this.tryUnlock();
            pam.start();

            event.accepted = true;
            return;
        }

        // U+007F is DEL, emitted on Delete key
        if (event.key === Qt.Key_Backspace || event.text == "\u{7f}") {
            if (this.password.length > 0) {
                this.password = this.password.slice(0, -1);
                this.backspace();

                if (this.password.length == 0) {
                    this.cleared();
                }
            }

            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_NumLock) {
            this.numlock = !this.numlock;
        } else if (event.modifiers & Qt.KeypadModifier) {
            // we're a numpad key, check whether we're a number or not
            if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                this.numlock = true;
            } else if (event.key >= Qt.Key_Escape) {
                this.numlock = false;
            }
        }

        if (event.key === Qt.Key_CapsLock) {
            this.capslock = !this.capslock;
        }

        if (event.text.length > 0) {
            // just in case, check whether capslock state is still right
            let isLetter = (event.text.toUpperCase() !== event.text.toLowerCase());
            if (isLetter) {
                let isUpper = (event.text === event.text.toUpperCase());
                let shiftPressed = (event.modifiers & Qt.ShiftModifier) !== 0;

                this.capslock = (isUpper && !shiftPressed) || (!isUpper && shiftPressed);
            }

            this.password += event.text;
            this.keypress();

            event.accepted = true;
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent

        source: `${Quickshell.shellDir}/assets/image/background.png`
        fillMode: Image.PreserveAspectCrop

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blurMax: 35
            blur: 1.0
        }
    }
    Shape {
        anchors.fill: parent

        ShapePath {
            startX: 0
            startY: 0

            PathLine {
                x: root.width + 1
                y: 0
            }
            PathLine {
                x: root.width + 1
                y: root.height + 1
            }
            PathLine {
                x: 0
                y: root.height + 1
            }
            PathLine {
                x: 0
                y: 0
            }

            fillGradient: RadialGradient {
                centerX: root.width / 2
                centerY: root.height / 2
                focalX: centerX
                focalY: centerY

                centerRadius: Math.hypot(root.width, root.height) / 2

                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: "transparent"
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.5)
                }
            }
        }
    }

    FontLoader {
        id: zeldaTextFont
        source: `${Quickshell.shellDir}/assets/font/HyliaSerifBeta.otf`
    }
    FontLoader {
        id: zeldaSymbolsFont
        source: `${Quickshell.shellDir}/assets/font/SSAncientHylian.ttf`
    }
    FontLoader {
        id: customSymbolsFont
        source: `${Quickshell.shellDir}/assets/font/CustomSymbols.ttf`
    }

    Item {
        id: centerContainer
        width: root.size * 0.5
        height: root.size * 0.5

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: parent.width * ((2031 + 1376 / 2) - (5333 / 2)) / 5333
        anchors.verticalCenterOffset: parent.height * ((885 + 1376 / 2) - (3000 / 2)) / 3000

        function getSymbolPosition(index) {
            let x = Math.cos(Math.PI * 2 / ring.model * index) * root.size * 0.16;
            let y = Math.sin(Math.PI * 2 / ring.model * index) * root.size * 0.16 + root.size * 0.016;
            return Qt.vector2d(x, y);
        }

        function getSymbolAbsolutePosition(index) {
            let cx = width / 2;
            let cy = height / 2;
            let relativePos = this.getSymbolPosition(index);
            return Qt.vector2d(cx + relativePos.x, cy + relativePos.y);
        }

        ListModel {
            id: connectionsModel
        }
        Repeater {
            id: connectionsContainer
            model: connectionsModel

            property real time: 0

            ShaderEffect {
                required property int index1
                required property int index2

                anchors.fill: parent

                property vector2d p1: centerContainer.getSymbolAbsolutePosition(index1)
                property vector2d p2: centerContainer.getSymbolAbsolutePosition(index2)
                property color color1: ring.itemAt(index1).glowColor
                property color color2: ring.itemAt(index2).glowColor
                property real intensity: Math.min(ring.itemAt(index1).glow, ring.itemAt(index2).glow)
                property real time: connectionsContainer.time
                property size resolution: Qt.size(width, height)

                fragmentShader: `${Quickshell.shellDir}/assets/shader/line.frag.qsb`
            }
        }
        NumberAnimation {
            target: connectionsContainer
            property: "time"
            from: 0
            to: 1000
            duration: 1000000
            loops: Animation.Infinite
            running: true
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            anchors.centerIn: parent

            text: Qt.formatDateTime(clock.date, "hh:mm:ss")
            font.family: zeldaTextFont.font.family
            font.pointSize: (root.size * 0.03) || 1
        }

        Repeater {
            id: ring
            model: 8

            readonly property color typingColor: Qt.rgba(0, 1, 1, 1)
            readonly property color deleteColor: Qt.rgba(1, 0, 1, 1)
            readonly property color clearColor: Qt.rgba(1, 0.5, 0, 1)
            readonly property color errorColor: Qt.rgba(1, 0, 0, 1)

            Text {
                id: ringText
                required property int index

                property double glow: 0
                property color glowColor: ring.typingColor
                property string symbol: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[Math.floor(26 * Math.random())]

                anchors.centerIn: parent
                anchors.horizontalCenterOffset: centerContainer.getSymbolPosition(index).x
                anchors.verticalCenterOffset: centerContainer.getSymbolPosition(index).y
                padding: 20

                text: symbol
                font.family: zeldaSymbolsFont.font.family
                font.pointSize: (root.size * 0.04) || 1

                layer.enabled: true
                layer.effect: ShaderEffect {
                    property real intensity: ringText.glow
                    property color glowColor: ringText.glowColor

                    property size pixelSize: Qt.size(1.0 / width, 1.0 / height)

                    fragmentShader: `${Quickshell.shellDir}/assets/shader/glow.frag.qsb`
                }
            }
        }

        Timer {
            id: unlockAnimation
            interval: 200
            running: root.isUnlocking
            repeat: true

            property int index: 0

            onTriggered: {
                ring.itemAt(this.index).glow = 0.0;
                this.index = (this.index + 1) % ring.model;
                ring.itemAt(this.index).glowColor = ring.typingColor;
                ring.itemAt(this.index).glow = 1.0;
            }
        }
        Timer {
            id: fadeAnimation
            interval: 15
            running: !root.isUnlocking
            repeat: true

            onTriggered: {
                for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                    const item = ring.itemAt(index);
                    if (item.glowColor != ring.errorColor && item.glow > 0.0) {
                        item.glow -= 0.01;
                    }
                }

                // garbage collect dead lines
                for (let i = connectionsModel.count - 1; i >= 0; i--) {
                    let conn = connectionsModel.get(i);
                    if (ring.itemAt(conn.index1).glow <= 0.0 || ring.itemAt(conn.index2).glow <= 0.0) {
                        connectionsModel.remove(i);
                    }
                }
            }
        }
        Connections {
            target: root

            function getNextItem() {
                const availableItems = [];
                let minItem = [0.0, Infinity];

                for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                    const item = ring.itemAt(index);
                    if (item.glow <= 0.0) {
                        availableItems.push(index);
                    } else if (item.glow < minItem[1]) {
                        minItem = [index, item.glow];
                    }
                }

                return availableItems.length > 0 ? availableItems[Math.floor(availableItems.length * Math.random())] : minItem[0];
            }

            function getLastActivatedItem() {
                const index = [0, 1, 2, 3, 4, 5, 6, 7].reduce((maxIndex, index) => ring.itemAt(maxIndex).glow > ring.itemAt(index).glow ? maxIndex : index);
                return ring.itemAt(index).glow > 0.0 ? index : null;
            }

            function handleNewConnection(prevIndex, newIndex) {
                if (prevIndex !== null) {
                    connectionsModel.append({
                        index1: prevIndex,
                        index2: newIndex
                    });
                }
            }

            function onKeypress() {
                const index = this.getNextItem();
                const prevIndex = this.getLastActivatedItem();
                const item = ring.itemAt(index);

                if (item.glowColor == ring.errorColor && item.glow == 1.0) {
                    for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                        ring.itemAt(index).glow = 0.0;
                    }
                }

                item.glowColor = ring.typingColor;
                item.glow = 1.0;

                this.handleNewConnection(prevIndex, index);
            }

            function onBackspace() {
                const index = this.getNextItem();
                const prevIndex = this.getLastActivatedItem();
                const item = ring.itemAt(index);

                item.glowColor = ring.deleteColor;
                item.glow = 1.0;

                this.handleNewConnection(prevIndex, index);
            }

            function onCleared() {
                connectionsModel.clear();

                for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                    const item = ring.itemAt(index);
                    item.glowColor = ring.clearColor;
                    item.glow = 1.0;
                }
            }

            function onTryUnlock() {
                connectionsModel.clear();

                for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                    ring.itemAt(index).glow = 0;
                }

                unlockAnimation.index = this.getLastActivatedItem() || Math.floor(Math.random() * 7);
                const currentItem = ring.itemAt(unlockAnimation.index);
                currentItem.glowColor = ring.typingColor;
                currentItem.glow = 1.0;
            }

            function onUnlockFailed() {
                connectionsModel.clear();

                for (const index of [0, 1, 2, 3, 4, 5, 6, 7]) {
                    const item = ring.itemAt(index);
                    item.glowColor = ring.errorColor;
                    item.glow = 1.0;
                }
            }

            function onCapslockChanged() {
                if (root.capslock) {
                    for (const itemIndex of [0, 2, 4, 6]) {
                        const item = ring.itemAt(itemIndex);
                        item.text = "A";
                        item.font.family = customSymbolsFont.font.family;
                    }
                } else {
                    for (const itemIndex of [0, 2, 4, 6]) {
                        const item = ring.itemAt(itemIndex);
                        item.text = item.symbol;
                        item.font.family = zeldaSymbolsFont.font.family;
                    }
                }
            }

            function onNumlockChanged() {
                if (!root.numlock) {
                    for (const itemIndex of [1, 3, 5, 7]) {
                        const item = ring.itemAt(itemIndex);
                        item.text = "B";
                        item.font.family = customSymbolsFont.font.family;
                    }
                } else {
                    for (const itemIndex of [1, 3, 5, 7]) {
                        const item = ring.itemAt(itemIndex);
                        item.text = item.symbol;
                        item.font.family = zeldaSymbolsFont.font.family;
                    }
                }
            }
        }
    }
}
