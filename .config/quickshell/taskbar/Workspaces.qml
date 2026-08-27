import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
  id: root
  spacing: 6

  required property var screen

  readonly property var workspaceRanges: ({
    "HDMI-A-1": { start: 1, end: 5 },
    "HDMI-A-2": { start: 6, end: 10 },
  })

  readonly property var range: workspaceRanges[screen.name] || { start: 1, end: 5 }
  readonly property int startId: range.start
  readonly property int count: range.end - range.start + 1

  Repeater {
    model: root.count

    Rectangle {
      required property int index

      readonly property int wsId: root.startId + index

      readonly property var ws: {
        const list = Hyprland.workspaces.values
        for (let i = 0; i < list.length; i++) {
          if (list[i].id === wsId)
            return list[i]
        }
        return null
      }

      readonly property bool isFocused: Hyprland.focusedWorkspace?.id === wsId
      readonly property bool isOccupied: ws !== null && ws.toplevels.count > 0
      readonly property bool isUrgent: ws?.urgent ?? false
      readonly property bool isActive: ws?.active ?? false

      width: 30
      height: 30
      radius: 6
      border.width: (isFocused || isUrgent || isActive) ? 0 : 1
      border.color: isFocused ? 'transparent' : '#00b3d7' 

      color: {
        if (isFocused) {
          return "#ffffff"
        }

        if (isActive) {
          return "#4a4a4a"
        }

        if (isUrgent) {
          return '#ff6a19'
        }

        if (mouseArea.containsMouse && !isFocused) {
          return '#4a4a4a'
        }

        if (isOccupied) {
          return '#00b6f8'
        }

        return "transparent"
      }

      Text {
        anchors.centerIn: parent
        text: wsId
        color: (isFocused || isUrgent) ? "#1e1e2e" : "#ffffff"
        font.family: "Noto Sans Serif"
        font.pixelSize: 12
        font.bold: (isFocused || isUrgent)
      }

      MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // onClicked: Hyprland.dispatch("workspace " + wsId)
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsId}" })`)
      }
    }
  }
}