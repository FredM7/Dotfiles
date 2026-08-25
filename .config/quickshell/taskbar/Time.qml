import Quickshell
import QtQuick

Text {
  id: timeText
  anchors.verticalCenter: parent.verticalCenter
  color: "#ffffff"
  font.family: "Noto Sans Serif"
  font.pixelSize: 14

  text: Qt.formatDateTime(clock.date, "ddd d MMM hh:mm:ss")

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Calendar {
    id: cal
    target: timeText
    closeTimer: closeTimer
  }
  
  property bool timeHovered: false

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: {
      timeText.timeHovered = true
      cal.viewDate = new Date()   // reset to current month
      cal.show = true
    }
    // onExited: cal.show = false
    onExited: {
      timeText.timeHovered = false
      // small delay so we can move onto the calendar
      closeTimer.restart()
    }
  }

  Timer {
    id: closeTimer
    interval: 300
    onTriggered: {
      if (!timeText.timeHovered && !cal.popupHovered)
        cal.show = false
    }
  }
}