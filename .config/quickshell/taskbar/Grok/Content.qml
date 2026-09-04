import QtQuick
import Quickshell

PopupWindow {
  property var target: null

  visible: target.open || hover.containsMouse || popupHover.containsMouse
  color: "transparent"

  anchor {
    item: btn
    margins.bottom: -4
    edges: Edges.Bottom | Edges.HorizontalCenter
    gravity: Edges.Bottom | Edges.HorizontalCenter
  }

  implicitWidth: card.implicitWidth
  implicitHeight: card.implicitHeight

  Rectangle {
    id: card
    implicitWidth: col.implicitWidth + 24
    implicitHeight: col.implicitHeight + 20
    radius: 8
    color: "#ee111111"
    border.color: "#44ffffff"
    border.width: 1

    MouseArea {
      id: popupHover
      anchors.fill: parent
      hoverEnabled: true
      onClicked: target.open = false
    }

    Column {
      id: col
      x: 12
      y: 10
      spacing: 6

      Text {
        font.family: "Noto Sans Serif"
        text: "Grok usage"
        color: "#ffffff"
        font.pixelSize: 16
        font.bold: true
      }

      Text {
        font.family: "Noto Sans Serif"
        text: Service.usedPercent < 0 ? Service.statusText : Service.usedPercent.toFixed(1) + "% used"
        color: Service.usedPercent >= 80 ? "#f7768e" : "#9ece6a"
        font.pixelSize: 16
      }

      Rectangle {
        width: 180
        height: 6
        radius: 3
        color: "#333333"

        Rectangle {
          width: parent.width * Math.max(0, Math.min(1, Service.usedPercent / 100))
          height: parent.height
          radius: 3
          color: Service.usedPercent >= 80 ? "#f7768e" : "#7aa2f7"
        }
      }

      Text {
        font.family: "Noto Sans Serif"
        visible: Service.resetAt.length > 0
        text: "Resets: " + Service.resetAt
        color: "#aaaaaa"
        font.pixelSize: 14
      }

      Text {
        font.family: "Noto Sans Serif"
        visible: Service.lastError.length > 0
        text: Service.lastError
        color: "#f7768e"
        font.pixelSize: 11
        width: 180
        wrapMode: Text.Wrap
      }

      Text {
        font.family: "Noto Sans Serif"
        text: target.open ? "click to unpin" : "click to pin"
        color: "#666666"
        font.pixelSize: 12
      }
    }
  }
}