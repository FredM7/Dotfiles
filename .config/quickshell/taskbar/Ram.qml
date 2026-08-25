import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root
  width: ramText.implicitWidth + 8
  height: 22

  property string ramTextValue: "…"

  Text {
    id: ramText
    anchors.centerIn: parent
    color: "#cdd6f4"
    font.family: "Noto Sans Serif"
    font.pixelSize: 14
    text: "RAM: " + root.ramTextValue
  }

  Process {
    id: memProc
    command: ["cat", "/proc/meminfo"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        let total = 0
        let available = 0

        const lines = this.text.split("\n")
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i]
          if (line.startsWith("MemTotal:"))
            total = parseInt(line.split(/\s+/)[1])
          else if (line.startsWith("MemAvailable:"))
            available = parseInt(line.split(/\s+/)[1])
        }

        if (total > 0) {
          const used = total - available
          const usedGiB = (used / 1024 / 1024).toFixed(1)
          const totalGiB = (total / 1024 / 1024).toFixed(1)
          root.ramTextValue = usedGiB + " / " + totalGiB + "GB"
        }
      }
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: memProc.running = true
  }
}