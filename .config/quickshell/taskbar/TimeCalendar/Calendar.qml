import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  property var target: null
  property date viewDate: new Date()

  signal requestClose()

  // Size — wide enough for 7 equal cells + gaps
  implicitWidth: 280
  implicitHeight: 300

  anchor.item: target
  anchor.edges: Edges.Bottom | Edges.HorizontalCenter
  anchor.gravity: Edges.Bottom | Edges.HorizontalCenter
  anchor.margins.top: 28

  color: "transparent"

  readonly property string fontFamily: "Noto Sans Serif"
  readonly property color cellBg: "#313244"
  readonly property color cellBgMuted: "#262637"
  readonly property color cellBorder: "#45475a"
  readonly property color todayBg: "#89b4fa"
  readonly property color textMain: "#cdd6f4"
  readonly property color textMuted: "#6c7086"
  readonly property color textHeader: "#a6adc8"
  readonly property color textToday: "#1e1e2e"
  readonly property color weekendText: "#bac2de"

  // 42 cells (6 weeks × 7 days), including adjacent-month days so columns stay full
  readonly property var cells: {
    const year = root.viewDate.getFullYear()
    const month = root.viewDate.getMonth()
    const first = new Date(year, month, 1)
    const startPad = (first.getDay() + 6) % 7 // Monday = 0
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const daysInPrev = new Date(year, month, 0).getDate()

    const today = new Date()
    const todayY = today.getFullYear()
    const todayM = today.getMonth()
    const todayD = today.getDate()

    let list = []
    // Leading days from previous month
    for (let i = startPad - 1; i >= 0; i--) {
      const d = daysInPrev - i
      const m = month === 0 ? 11 : month - 1
      const y = month === 0 ? year - 1 : year
      list.push({
        day: d,
        inMonth: false,
        isToday: y === todayY && m === todayM && d === todayD,
        isWeekend: false // filled below via index
      })
    }
    // Current month
    for (let d = 1; d <= daysInMonth; d++) {
      list.push({
        day: d,
        inMonth: true,
        isToday: year === todayY && month === todayM && d === todayD,
        isWeekend: false
      })
    }
    // Trailing days into next month to fill 6 weeks
    let next = 1
    while (list.length < 42) {
      const m = month === 11 ? 0 : month + 1
      const y = month === 11 ? year + 1 : year
      const d = next++
      list.push({
        day: d,
        inMonth: false,
        isToday: y === todayY && m === todayM && d === todayD,
        isWeekend: false
      })
    }
    // Weekend flag from column index (0=Mon … 5=Sat, 6=Sun)
    for (let i = 0; i < list.length; i++) {
      const col = i % 7
      list[i].isWeekend = col >= 5
    }
    return list
  }

  onVisibleChanged: {
    if (visible) {
      armTimer.restart()
    } else {
      armTimer.stop()
      grab.active = false
    }
  }

  Timer {
    id: armTimer
    interval: 150
    repeat: false
    onTriggered: {
      if (root.visible)
        grab.active = true
    }
  }

  HyprlandFocusGrab {
    id: grab
    windows: [root]
    onCleared: {
      if ((root.target && root.target.buttonOwnsClick) || armTimer.running || !root.visible)
        return
      root.requestClose()
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 10
    border.color: "#45475a"
    border.width: 1

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 10

      // Header: month + year + arrows
      RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Rectangle {
          Layout.preferredWidth: 28
          Layout.preferredHeight: 28
          radius: 6
          color: prevHover.containsMouse ? "#45475a" : "transparent"

          // Drawn chevron — font glyphs (‹ ›) have uneven bearings so they look off-center
          Canvas {
            anchors.centerIn: parent
            width: 10
            height: 14
            onPaint: {
              const ctx = getContext("2d")
              ctx.reset()
              ctx.strokeStyle = root.textMain
              ctx.lineWidth = 1.75
              ctx.lineCap = "round"
              ctx.lineJoin = "round"
              ctx.beginPath()
              ctx.moveTo(7.5, 1.5)
              ctx.lineTo(2.5, 7)
              ctx.lineTo(7.5, 12.5)
              ctx.stroke()
            }
          }
          MouseArea {
            id: prevHover
            anchors.fill: parent
            hoverEnabled: true
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
          color: root.textMain
          font.family: root.fontFamily
          font.pixelSize: 14
          font.bold: true
        }

        Rectangle {
          Layout.preferredWidth: 28
          Layout.preferredHeight: 28
          radius: 6
          color: nextHover.containsMouse ? "#45475a" : "transparent"

          Canvas {
            anchors.centerIn: parent
            width: 10
            height: 14
            onPaint: {
              const ctx = getContext("2d")
              ctx.reset()
              ctx.strokeStyle = root.textMain
              ctx.lineWidth = 1.75
              ctx.lineCap = "round"
              ctx.lineJoin = "round"
              ctx.beginPath()
              ctx.moveTo(2.5, 1.5)
              ctx.lineTo(7.5, 7)
              ctx.lineTo(2.5, 12.5)
              ctx.stroke()
            }
          }
          MouseArea {
            id: nextHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              const d = new Date(root.viewDate)
              d.setMonth(d.getMonth() + 1)
              root.viewDate = d
            }
          }
        }
      }

      // One grid for headers + days so columns share the same widths
      GridLayout {
        id: calGrid
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 7
        rowSpacing: 3
        columnSpacing: 3
        uniformCellWidths: true
        uniformCellHeights: false

        Repeater {
          model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
          Item {
            required property int index
            required property string modelData
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.minimumWidth: 1

            Text {
              anchors.centerIn: parent
              text: modelData
              color: index >= 5 ? root.weekendText : root.textHeader
              font.family: root.fontFamily
              font.pixelSize: 12
              font.weight: Font.Black
            }
          }
        }

        Repeater {
          model: root.cells

          Rectangle {
            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 1
            Layout.preferredHeight: 30
            Layout.minimumHeight: 26
            radius: 6

            readonly property bool isToday: modelData.isToday
            readonly property bool inMonth: modelData.inMonth
            readonly property bool isWeekend: modelData.isWeekend

            color: {
              if (isToday)
                return root.todayBg
              if (!inMonth)
                return root.cellBgMuted
              return root.cellBg
            }
            border.width: isToday ? 0 : 1
            border.color: root.cellBorder
            opacity: inMonth || isToday ? 1.0 : 0.85

            Text {
              anchors.centerIn: parent
              text: modelData.day
              font.family: root.fontFamily
              font.pixelSize: 12
              font.bold: isToday
              color: {
                if (isToday)
                  return root.textToday
                if (!inMonth)
                  return root.textMuted
                if (isWeekend)
                  return root.weekendText
                return root.textMain
              }
            }
          }
        }
      }
    }
  }
}
