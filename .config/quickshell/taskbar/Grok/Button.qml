import QtQuick
import Quickshell
// import Qt5Compat.GraphicalEffects

Item {
  id: root
  implicitWidth: btn.implicitWidth
  implicitHeight: 28

  property bool open: false

  function accentColor() {
    if (Service.usedPercent >= 100 && Service.additionalCredits >= 0)
      return '#f54e34';
    if (Service.usedPercent >= 80)
      return "#e8ff17";
    return "#eeeeee";
  }

  Rectangle {
    id: btn
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: label.implicitWidth + 16
    implicitHeight: 30
    radius: 6
    color: (hover.containsMouse || root.open) ? "#33ffffff" : "#22ffffff"

    

    Row {
      id: label
      anchors.centerIn: parent
      spacing: 6

      Icon {
        iconColor: root.accentColor()
      }

      Text {
        font.family: "Noto Sans Serif"
        anchors.verticalCenter: parent.verticalCenter
        text: {
          if (Service.usedPercent < 0)
            return "0%"
          if (Service.usedPercent >= 100 && Service.additionalCredits >= 0)
            return "$" + (Service.additionalCredits / 100).toFixed(2)
          return Service.usedPercent.toFixed(0) + "%"
        }
        color: root.accentColor()
        font.pixelSize: 14
      }
    }

    MouseArea {
      id: hover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        root.open = !root.open
        if (root.open)
          Service.refresh()
      }
    }
  }

  Content {
    target: root
  }
}
