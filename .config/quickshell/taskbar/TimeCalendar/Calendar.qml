import Quickshell
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  property var target: null
  property bool show: false
  property bool popupHovered: false
  property var closeTimer

  visible: show //&& target !== null

  // Size
  implicitWidth: 260
  implicitHeight: 280

  anchor.item: target
  anchor.edges: Edges.Bottom | Edges.HorizontalCenter
  anchor.gravity: Edges.Bottom | Edges.HorizontalCenter
  anchor.margins.top: 28

  color: "transparent"

  // Current viewing month
  property date viewDate: new Date()

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 10
    border.color: "#45475a"
    border.width: 1

    // Keep the popup open while mouse is over it
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: root.popupHovered = true
      onExited: {
        root.popupHovered = false
        // hideTimer.restart()
        root.closeTimer.restart()
      }
      // let clicks through to the arrows / days
      propagateComposedEvents: true
      onClicked: (mouse) => { mouse.accepted = false }
    }

    // Timer {
    //   id: hideTimer
    //   interval: 250
    //   onTriggered: {
    //     // Only close if the mouse is no longer over the calendar
    //     // (Time.qml will re-open it if you move back to the clock)
    //     if (!root.popupHovered)
    //       root.show = false
    //   }
    // }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      // Header: month + year + arrows
      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "‹"
          color: "#cdd6f4"
          font.pixelSize: 18
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              const d = new Date(root.viewDate)
              d.setMonth(d.getMonth() - 1)
              root.viewDate = d
            }
          }
        }

        Text {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatDate(root.viewDate, "MMMM yyyy")
          color: "#cdd6f4"
          font.pixelSize: 14
          font.bold: true
        }

        Text {
          text: "›"
          color: "#cdd6f4"
          font.pixelSize: 18
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              const d = new Date(root.viewDate)
              d.setMonth(d.getMonth() + 1)
              root.viewDate = d
            }
          }
        }
      }

      // Day names
      RowLayout {
        Layout.fillWidth: true
        spacing: 0
        Repeater {
          model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
          Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: modelData
            color: "#a6adc8"
            font.pixelSize: 11
          }
        }
      }

      // Days grid
      GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 7
        rowSpacing: 2
        columnSpacing: 2

        Repeater {
          model: {
            const year = root.viewDate.getFullYear()
            const month = root.viewDate.getMonth()
            const first = new Date(year, month, 1)
            // Monday = 0
            let startDay = (first.getDay() + 6) % 7
            const daysInMonth = new Date(year, month + 1, 0).getDate()

            let cells = []
            for (let i = 0; i < startDay; i++)
              cells.push({ day: 0, current: false })
            for (let d = 1; d <= daysInMonth; d++)
              cells.push({ day: d, current: true })
            return cells
          }

          Rectangle {
            required property var modelData
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6

            readonly property bool isToday: {
              if (!modelData.current) return false
              const today = new Date()
              return modelData.day === today.getDate()
                  && root.viewDate.getMonth() === today.getMonth()
                  && root.viewDate.getFullYear() === today.getFullYear()
            }

            // color: {
            //   if (!modelData.current) return "transparent"
            //   const today = new Date()
            //   if (modelData.day === today.getDate()
            //       && root.viewDate.getMonth() === today.getMonth()
            //       && root.viewDate.getFullYear() === today.getFullYear())
            //     return "#89b4fa"
            //   return "transparent"
            // }
            color: isToday ? "#89b4fa" : "transparent"

            Text {
              anchors.centerIn: parent
              text: modelData.current ? modelData.day : ""
              // color: parent.color === "#89b4fa" ? "#1e1e2e" : "#cdd6f4"
              color: isToday ? "#1e1e2e" : "#cdd6f4"
              font.pixelSize: 12
              font.bold: parent.color === "#89b4fa"
            }
          }
        }
      }
    }
  }
}