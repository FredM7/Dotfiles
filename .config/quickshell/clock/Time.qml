pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root
  // property string time

  // Process {
  //   id: dateProc
  //   command: ["date"]
  //   running: true

  //   stdout: StdioCollector {
  //     onStreamFinished: root.time = this.text
  //   }
  // }

  // Timer {
  //   interval: 1000
  //   running: true
  //   repeat: true
  //   onTriggered: dateProc.running = true
  // }

  // an expression can be broken across multiple lines using {}
  readonly property string time: {
    // The passed format string matches the default output of
    // the `date` command.
    // Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy")
    Qt.formatDateTime(clock.date, "ddd d MMM hh:mm:ss")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}