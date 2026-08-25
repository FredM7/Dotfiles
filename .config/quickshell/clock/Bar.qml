import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  // id: root
  // property string time

  // Time {
  //   id: timeSource
  // }

  Variants {
    model: Quickshell.screens

    // delegate: Component {
      PanelWindow {
        required property var modelData
        screen: modelData

        color: "#aa000000"

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 40

        // Text {
        //   // id: clock
        //   anchors.centerIn: parent

        //   text: root.time
        // }
         ClockWidget {
          anchors.centerIn: parent
          // time: root.time
          // time: timeSource.time
        }
      }
    // }
  }

  // Process {
  //   id: dateProc
  //   command: ["date"]
  //   running: true

  //   stdout: StdioCollector {
  //     // onStreamFinished: clock.text = this.text
  //     onStreamFinished: root.time = this.text
  //   }
  // }

  // Timer {
  //   interval: 1000
  //   running: true
  //   repeat: true
  //   onTriggered: dateProc.running = true
  // }
}