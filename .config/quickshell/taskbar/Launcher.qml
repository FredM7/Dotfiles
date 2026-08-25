import Quickshell
import QtQuick

Rectangle {
  width: 30
  height: 30
  radius: 6
  color: launcherMa.containsMouse ? '#ffffff' : "transparent"

  Text {
    anchors.centerIn: parent
    text: "󰣇"          // or "󰕰" / "" — change to whatever you like
    color: launcherMa.containsMouse ? '#000000' : "#1e53ff" 
    font.pixelSize: 28
  }

  MouseArea {
    id: launcherMa
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])
    // Alternatives:
    // Quickshell.execDetached(["wofi", "--show", "drun"])
    // Quickshell.execDetached(["fuzzel"])
    // Quickshell.execDetached(["dmenu_run"])
  }
}