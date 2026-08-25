import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: root
  width: cpuText.implicitWidth + 8
  height: 22

  property real usage: 0
  // property int lastIdle: 0
  // property int lastTotal: 0
  property var last: null

  Text {
    id: cpuText
    anchors.centerIn: parent
    color: "#cdd6f4"
    font.pixelSize: 16
    // text: "󰻠  " + Math.round(root.usage) + "%"
    text: "󰻠  " + root.usage.toFixed(0) + "%"
  }

  Process {
    id: statProc
    command: ["cat", "/proc/stat"]
    running: true

    stdout: StdioCollector {
      // onStreamFinished: {
      //   // First line: cpu  user nice system idle iowait irq softirq ...
      //   const line = this.text.trim().split("\n")[0]
      //   const parts = line.split(/\s+/).slice(1).map(Number)

      //   // console.log("asdad", parts);

      //   const idle = parts[3]
      //   const total = parts.reduce((a, b) => a + b, 0)

      //   if (root.lastTotal > 0) {
      //     const idleDelta = idle - root.lastIdle
      //     const totalDelta = total - root.lastTotal
      //     root.usage = totalDelta > 0
      //       ? (1 - idleDelta / totalDelta) * 100
      //       : 0
      //   }

      //   root.lastIdle = idle
      //   root.lastTotal = total
      // }
      onStreamFinished: {
        const line = this.text.trim().split("\n")[0]
        const parts = line.split(/\s+/).slice(1).map(n => parseInt(n, 10))

        // idle + iowait is the usual definition of "idle"
        const idle = parts[3] + parts[4]
        const total = parts.reduce((a, b) => a + b, 0)

        if (root.last !== null) {
          const idleDelta = idle - root.last.idle
          const totalDelta = total - root.last.total

          if (totalDelta > 0) {
            root.usage = (1 - idleDelta / totalDelta) * 100
          }
        }

        // store for next sample
        root.last = { idle: idle, total: total }
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: statProc.running = true
  }
}