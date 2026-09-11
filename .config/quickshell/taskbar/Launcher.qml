import Quickshell
import QtQuick
import Quickshell.Hyprland

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
    // onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])
    onClicked: Hyprland.dispatch('hl.dsp.exec_cmd("quickshell -c launcher ipc call launcher toggle")')
    // onClicked: Quickshell.execDetached([
    //   "env",
    //   "-u", "QS_CONFIG_NAME",
    //   "-u", "QS_CONFIG_PATH",
    //   "-u", "QS_MANIFEST",
    //   "quickshell", "-c", "launcher", "ipc", "call", "launcher", "toggle"
    // ])
  }
}