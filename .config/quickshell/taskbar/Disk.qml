import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root
  width: diskText.implicitWidth + 8
  height: 22

  property string mount: "/"          // change to "/home" if you prefer
  property string diskTextValue: "..."

  Text {
    id: diskText
    anchors.centerIn: parent
    color: "#cdd6f4"
    font.family: "Noto Sans Serif"
    font.pixelSize: 14
    text: "SSD: " + root.diskTextValue
  }

  // Run df and parse free space
  Process {
    id: dfProc
    command: ["df", "-h", "--output=used,size", root.mount]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        // df output looks like:
        // Avail
        //  120G
        // const lines = this.text.trim().split("\n")
        // if (lines.length >= 2)
        //   root.freeText = lines[1].trim()
        const lines = this.text.trim().split("\n")
        if (lines.length >= 2) {
          const parts = lines[1].trim().split(/\s+/)
          if (parts.length >= 2)
            root.diskTextValue = parts[0] + " / " + parts[1]
        }
      }
    }
  }

  // Refresh every 30 seconds
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: dfProc.running = true
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: dfProc.running = true   // manual refresh
  }
}