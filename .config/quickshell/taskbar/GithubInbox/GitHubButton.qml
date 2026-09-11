import QtQuick
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
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13

    Rectangle {
        id: btn
        implicitWidth: row.implicitWidth + 14
        implicitHeight: 30
        radius: 4
        color: btnArea.containsMouse || root.open ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: ""
                color: GitHubService.unread > 0 ? root.accent : root.fg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
            }
            Text {
                visible: GitHubService.unread > 0
                text: GitHubService.unread > 99 ? "99+" : "" + GitHubService.unread
                color: root.accent
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 1
                font.bold: true
            }
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton)
                    root.open = !root.open;
                else
                    GitHubService.refresh();
            }
        }
    }

    InboxPanel {
        visible: root.open
        anchorItem: root
        service: GitHubService
        fg: root.fg
        muted: root.muted
        accent: root.accent
        bg: root.bg
        borderColor: root.border
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        onRequestClose: root.open = false
    }
}