import Quickshell
import QtQuick

Text {
  id: timeText
  anchors.verticalCenter: parent.verticalCenter
  color: "#ffffff"
  font.family: "Noto Sans Serif"
  font.pixelSize: 14

  text: Qt.formatDateTime(clock.date, "ddd d MMM hh:mm:ss")

  property bool open: false
  // Prevent the focus-grab clear from immediately closing when the toggle click lands.
  property bool buttonOwnsClick: false

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Calendar {
    id: cal
    target: timeText
    visible: timeText.open
    onRequestClose: timeText.open = false
    onVisibleChanged: {
      if (!visible)
        timeText.open = false
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onPressed: timeText.buttonOwnsClick = true
    onReleased: timeText.buttonOwnsClick = false
    onCanceled: timeText.buttonOwnsClick = false
    onClicked: {
      timeText.open = !timeText.open
      if (timeText.open)
        cal.viewDate = new Date() // reset to current month when opening
    }
  }
}
