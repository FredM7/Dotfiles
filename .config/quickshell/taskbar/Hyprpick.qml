import Quickshell
import QtQuick

Rectangle {
  width: 30
  height: 30
  radius: 6
  color: pickerMa.containsMouse ? "#ffffff" : "transparent"

  Text {
    anchors.centerIn: parent
    text: ""          // or ""
    color: pickerMa.containsMouse ? "#000000" : '#12d200'
    font.pixelSize: 20
  }

  MouseArea {
    id: pickerMa
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["hyprpicker"])
  }
}