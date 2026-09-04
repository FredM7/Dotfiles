import QtQuick
import Quickshell.Services.Mpris

Rectangle {
  id: root

  property var player: null
  property color barColor: "#1ed760"
  property color trackColor: "#661ed760"
  property int barHeight: 3

  // implicitWidth: 80
  implicitHeight: barHeight
  height: barHeight
  color: trackColor
  radius: height / 2
  // z: 10

  readonly property real progress: {
    if (!player || !player.length || player.length <= 0)
      return 0
    const pos = player.position || 0
    return Math.max(0, Math.min(1, pos / player.length))
  }

  function seekAt(x) {
    if (!player || !player.length || width <= 0)
      return
    const target = Math.max(0, Math.min(1, x / width)) * player.length
    const current = player.position || 0
    if (player.canSeek)
      player.seek(target - current)
    else
      player.position = target
    player.positionChanged()
  }

  FrameAnimation {
    running: root.player && root.player.isPlaying
    onTriggered: root.player.positionChanged()
  }

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Math.max(0, parent.width * root.progress)
    radius: parent.radius
    color: root.barColor
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.player && root.player.length > 0
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: (mouse) => root.seekAt(mouse.x)
    onPositionChanged: (mouse) => {
      if (pressed)
        root.seekAt(mouse.x)
    }
  }
}
