import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

Item {
    id: root
    implicitWidth: btn.implicitWidth
    implicitHeight: btn.implicitHeight

    property bool open: false

    property color fg: "#e6e6e6"
    property color muted: "#9aa0a6"
    property color accent: "#f78166"
    property color bg: "#1c1c1c"
    property color border: "#333"
    property string fontFamily: "Noto Sans Serif"
    property int fontSize: 16
    property int iconSize: 17
    property url icon: Qt.resolvedUrl("github.svg")

    readonly property int count: Service.count
    readonly property bool busy: Service.status === "loading"

    Rectangle {
        id: btn
        implicitWidth: row.implicitWidth + 14
        implicitHeight: 30
        radius: 4
        color: btnArea.containsMouse || root.open ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6
            height: root.iconSize

            Item {
                Layout.preferredWidth: root.iconSize
                Layout.preferredHeight: root.iconSize
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: icon
                    anchors.fill: parent
                    source: root.icon
                    sourceSize.width: root.iconSize
                    sourceSize.height: root.iconSize
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent
                    source: icon
                    colorization: 1
                    colorizationColor: root.count > 0 ? root.accent : root.fg
                }
            }

            Item {
                visible: root.count > 0
                Layout.preferredWidth: countText.implicitWidth
                Layout.preferredHeight: root.iconSize
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: Service.countLabel
                    color: root.accent
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    // font.bold: true
                }
            }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton)
                    panel.buttonOwnsClick = true;
            }
            onReleased: panel.buttonOwnsClick = false
            onCanceled: panel.buttonOwnsClick = false
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    root.open = !root.open;
                    if (root.open)
                        Service.refresh();
                } else {
                    Service.refresh();
                }
            }
        }
    }

    Panel {
        id: panel
        visible: root.open
        anchorItem: root
        fg: root.fg
        muted: root.muted
        accent: root.accent
        bg: root.bg
        borderColor: root.border
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        onRequestClose: root.open = false
        onVisibleChanged: {
            if (!visible)
                root.open = false;
        }
    }
}