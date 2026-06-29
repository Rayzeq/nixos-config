pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import org.kde.kirigami 2.20 as Kirigami
import RustExtensions

import ".."

PanelWindow {
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    anchors {
        bottom: true
        left: true
        right: true
    }
    margins {
        bottom: 10
        left: 10
        right: 10
    }
    implicitHeight: 400

    color: "transparent"

    ClipboardManager {
        id: backend
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "closewindow") {
                backend.checkClipboard();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.window
        radius: 16

        ListView {
            anchors.fill: parent
            anchors.margins: 12

            model: backend
            orientation: ListView.Horizontal
            spacing: 12

            clip: true
            flickableDirection: Flickable.HorizontalFlick

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton

                onWheel: wheel => {
                    let newX = parent.contentX - wheel.angleDelta.y;
                    let maxX = Math.max(0, parent.contentWidth - parent.width);

                    parent.contentX = Math.max(0, Math.min(newX, maxX));
                    wheel.accepted = true;
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 500
                    easing.type: Easing.OutQuad
                }
            }

            displaced: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "x"
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        property: "opacity"
                        to: 1.0
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }
            }

            delegate: DelegateChooser {
                role: "type"

                DelegateChoice {
                    roleValue: "image"

                    ClipboardItem {
                        id: imageCard
                        icon: "x-shape-image-symbolic"
                        title: "Image"

                        required property string imageData

                        Image {
                            anchors.fill: parent
                            source: imageCard.imageData
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "file"

                    ClipboardItem {
                        id: fileCard
                        icon: pathsList.length > 1 ? "folder-symbolic" : "file-symbolic"
                        title: pathsList.length > 1 ? "Files" : "File"

                        required property string paths
                        property list<string> pathsList: paths.split("\n")

                        function getBasePath(paths) {
                            if (!paths || paths.length === 0)
                                return "";

                            return paths.reduce((commonPath, currentPath) => {
                                const p1 = commonPath.split('/');
                                const p2 = currentPath.split('/');

                                let i = 0;
                                while (i < p1.length && i < p2.length && p1[i] === p2[i])
                                    i++;

                                return p1.slice(0, i).join('/');
                            });
                        }

                        property string prefix: getBasePath(pathsList)
                        // maximum number of entries when there are multiple files
                        property int maxEntries: 8

                        ColumnLayout {
                            id: fileCardContent

                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 10

                                text: fileCard.pathsList.length > 1 ? fileCard.prefix : fileCard.pathsList[0]
                                color: Theme.textPrimary
                                font.italic: true
                                font.pixelSize: 14
                                wrapMode: fileCard.pathsList.length > 1 ? Text.NoWrap : Text.Wrap
                                elide: Text.ElideLeft
                            }

                            Repeater {
                                id: fileList

                                property int itemCount: Math.min(fileCard.pathsList.length, fileCard.maxEntries)
                                model: itemCount + (itemCount !== fileCard.pathsList.length ? 1 : 0)

                                delegate: ItemDelegate {
                                    required property int index

                                    Layout.fillWidth: true

                                    visible: fileCard.pathsList.length > 1

                                    background: Rectangle {
                                        color: Theme.cardSecondaryBg
                                        topLeftRadius: index === 0 ? 10 : 0
                                        topRightRadius: index === 0 ? 10 : 0
                                        bottomLeftRadius: (index + 1) === fileList.model ? 10 : 0
                                        bottomRightRadius: (index + 1) === fileList.model ? 10 : 0
                                    }

                                    contentItem: Text {
                                        property bool isLastSpecial: fileList.itemCount !== fileCard.pathsList.length && (index + 1) === fileList.model

                                        text: isLastSpecial ? `${fileCard.pathsList.length - fileList.itemCount} more files` : fileCard.pathsList[index].replace(new RegExp(`^${fileCard.prefix}/`), "")
                                        elide: Text.ElideLeft
                                        color: isLastSpecial ? Theme.textSecondary : Theme.textPrimary
                                        font.italic: !isLastSpecial
                                    }

                                    Kirigami.Separator {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        visible: (index + 1) !== fileList.model
                                    }
                                }
                            }
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "url"

                    ClipboardItem {
                        id: urlCard
                        icon: "link-symbolic"
                        title: "Link"

                        required property string url
                        required property bool isLoading
                        required property string imageUrl
                        required property string linkTitle
                        required property string description

                        ColumnLayout {
                            anchors.fill: parent

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: image.sourceSize.width > 0 ? width * (image.sourceSize.height / image.sourceSize.width) : 0
                                Layout.minimumHeight: 0
                                visible: urlCard.isLoading || urlCard.imageUrl !== ""

                                Image {
                                    id: image
                                    anchors.fill: parent

                                    source: urlCard.imageUrl
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            Text {
                                Layout.fillWidth: true

                                visible: urlCard.isLoading || urlCard.linkTitle !== ""
                                text: urlCard.isLoading ? "<loading>" : urlCard.linkTitle
                                elide: Text.ElideRight
                                font.pixelSize: 15
                                font.bold: true
                                color: Theme.textPrimary
                            }

                            Text {
                                Layout.fillWidth: true

                                visible: urlCard.isLoading || urlCard.description !== ""
                                text: urlCard.isLoading ? "<loading>" : urlCard.description
                                elide: Text.ElideRight
                                font.pixelSize: 14
                                color: Theme.textPrimary
                            }

                            Text {
                                Layout.fillWidth: true

                                text: urlCard.url.toString()
                                font.pixelSize: 12
                                wrapMode: !urlCard.isLoading && urlCard.linkTitle === "" && urlCard.description === "" ? Text.Wrap : Text.NoWrap
                                elide: Text.ElideRight
                                color: Theme.light ? "#2222ff" : "#7777ff"
                            }

                            // spring to push everything up if it doesn't fill the whole card
                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "color"

                    ClipboardItem {
                        id: colorCard
                        icon: "color-picker-symbolic"

                        required property color color

                        property string formattedColor: [color.r, color.g, color.b, ...(color.a === 1 ? [] : [color.a])].map(number => Math.round(number * 255).toString(16).padStart(2, "0")).join("")
                        title: `Color · <span style="font-weight: normal">${formattedColor}</span>`

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: colorCard.color
                            border.color: Theme.cardBorder
                            border.width: 1
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "code"

                    ClipboardItem {
                        id: codeCard
                        icon: "format-text-code-symbolic"
                        title: `Code · <span style="font-weight: normal">${language}</span>`

                        required property string language
                        required property string codeLight
                        required property string codeDark

                        Text {
                            anchors.fill: parent

                            color: Theme.textPrimary
                            textFormat: Text.RichText
                            elide: Text.ElideRight
                            font.pixelSize: 12

                            property string lightCode: codeCard.codeLight.replace(/\t/g, "  ").split("\n").map((line, i) => `<span style="color: #9A9996">${i.toString().padEnd(2, " ")}</span> ${line}`).join("\n")
                            property string darkCode: codeCard.codeDark.replace(/\t/g, "  ").split("\n").map((line, i) => `<span style="color: #777777">${i.toString().padEnd(2, " ")}</span> ${line}`).join("\n")

                            text: `
                                <style>
                                    code {
                                        white-space: pre;
                                        font-family: monospace;
                                    }
                                </style>
                                <code>${Theme.light ? lightCode : darkCode}</code>
                            `
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "text"

                    ClipboardItem {
                        id: textCard
                        icon: "text-symbolic"
                        title: "Text"

                        required property string text

                        Text {
                            anchors.fill: parent
                            text: textCard.text
                            color: Theme.textPrimary
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }

    component ClipboardItem: Rectangle {
        id: root

        required property int index

        required property string icon
        required property string title
        default property list<Item> contentChildren: []

        width: 260
        height: parent?.height
        radius: 12

        color: hoverHandler.hovered ? Theme.cardHover : Theme.cardBg
        border.color: Theme.cardBorder
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Kirigami.Icon {
                    source: root.icon
                    implicitWidth: 20
                    implicitHeight: 20
                }

                Text {
                    Layout.fillWidth: true

                    text: root.title
                    color: Theme.textSecondary
                    font.bold: true
                    font.pixelSize: 15
                    textFormat: Text.RichText
                }

                Button {
                    Layout.alignment: Qt.AlignRight

                    icon.name: "delete-symbolic"

                    background: Rectangle {
                        implicitHeight: 27
                        implicitWidth: 27

                        color: deleteHoverHandler.hovered ? Theme.buttonBackgroundHover : Theme.buttonBackground
                        radius: this.width

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    onClicked: {
                        backend.remove(root.index);
                    }

                    HoverHandler {
                        id: deleteHoverHandler
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                children: root.contentChildren
            }
        }

        HoverHandler {
            id: hoverHandler
        }

        TapHandler {
            onTapped: backend.copy(root.index)
        }
    }
}
