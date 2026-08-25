import Quickshell
import QtQuick

Rectangle {
  width: 30
  height: 30
  radius: 6
  color: btopMa.containsMouse ? '#ffffff' : "transparent"

  Text {
    anchors.centerIn: parent
    text: "󰨇"          // or ""
    color: btopMa.containsMouse ? "#000000" : '#ebb400'
    font.pixelSize: 20
  }

  MouseArea {
    id: btopMa
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
    // Change "kitty" to your terminal if different (foot, alacritty, etc.)
  }
}