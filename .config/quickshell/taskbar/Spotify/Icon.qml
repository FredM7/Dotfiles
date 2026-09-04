import QtQuick
import QtQuick.Effects

Item {
  id: root
  width: 18
  height: 18
  anchors.verticalCenter: parent.verticalCenter
  
  property color iconColor: "white"

  Image {
    id: svgIcon
    anchors.fill: parent
    source: Qt.resolvedUrl("spotify.svg")
    sourceSize.width: 18
    sourceSize.height: 18
    smooth: true
    visible: false
  }

  MultiEffect {
    anchors.fill: svgIcon
    source: svgIcon
    colorization: 1.0
    colorizationColor: root.iconColor
  }
}