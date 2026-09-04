import QtQuick
import Quickshell

Item {
  id: root
  implicitWidth: btn.implicitWidth
  implicitHeight: 28

  property bool open: false

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

      Image {
        anchors.verticalCenter: parent.verticalCenter
        source: Qt.resolvedUrl("grok.svg")
        width: 18
        height: 18
        smooth: true
      }

      Text {
        font.family: "Noto Sans Serif"
        anchors.verticalCenter: parent.verticalCenter
        text: Service.usedPercent < 0 ? "…" : Service.usedPercent.toFixed(0) + "%"
        color: Service.usedPercent >= 80 ? "#f7768e" : "#eeeeee"
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
