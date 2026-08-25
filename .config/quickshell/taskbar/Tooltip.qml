import Quickshell
import QtQuick

PopupWindow {
  id: root

  property string text: ""
  property Item target: null
  property bool show: false

  // Only show when we have a target and text
  // visible: target !== null && text !== ""
  visible: show && target !== null

  // Size to content
  implicitWidth: tipText.implicitWidth + 14
  implicitHeight: tipText.implicitHeight + 10

  // Anchor below the hovered icon
  anchor.item: target
  anchor.edges: Edges.Bottom | Edges.Left
  anchor.gravity: Edges.Bottom | Edges.Left
  anchor.margins.top: 6

  color: "transparent"

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 6
    border.color: "#45475a"
    border.width: 1

    Text {
      id: tipText
      anchors.centerIn: parent
      text: root.text
      color: "#cdd6f4"
      font.pixelSize: 12
    }
  }
}