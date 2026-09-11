import QtQuick

Rectangle {
    id: root

    property alias text: input.text
    property alias inputItem: input
    property color fg: "#e6e6e6"
    property color muted: "#9aa0a6"
    property color accent: "#f78166"
    property color bg: "#1c1c1c"
    property color borderColor: "#333"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13
    property string placeholder: "filter author, title, repo, branch…"

    signal requestClose()

    implicitHeight: 26
    radius: 4
    color: Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    border.color: input.activeFocus ? root.accent : root.borderColor

    function focusInput() {
        input.forceActiveFocus();
    }

    function clear() {
        input.text = "";
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholder
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: root.fontSize - 1
        visible: input.text.length === 0
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onPressed: {
            input.forceActiveFocus();
            mouse.accepted = false;
        }
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: clearBtn.width + 10
        verticalAlignment: TextInput.AlignVCenter
        focus: true
        activeFocusOnTab: true
        color: root.fg
        selectedTextColor: root.bg
        selectionColor: root.accent
        font.family: root.fontFamily
        font.pixelSize: root.fontSize - 1
        clip: true
        Keys.onEscapePressed: {
            if (text.length)
                text = "";
            else
                root.requestClose();
        }
    }

    Text {
        id: clearBtn
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: "✕"
        color: root.muted
        font.pixelSize: root.fontSize - 2
        visible: input.text.length > 0
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.clear();
                root.focusInput();
            }
        }
    }
}