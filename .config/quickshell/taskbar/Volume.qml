import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Item {
  id: root
  width: volText.implicitWidth + 8
  height: 22

  // Keep the default sink tracked
  PwObjectTracker {
    objects: [ Pipewire.defaultAudioSink ]
  }

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property real volume: sink?.audio.volume ?? 0
  readonly property bool muted: sink?.audio.muted ?? false

  Text {
    id: volText
    anchors.centerIn: parent
    color: root.muted ? "#f38ba8" : "#cdd6f4"
    font.family: "Noto Sans Serif"
    font.pixelSize: 14

    text: {
      if (root.muted)
        return "󰝟  muted"
      return "󰕾  " + Math.round(root.volume * 100) + "%"
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    // Click = toggle mute
    onClicked: (mouse) => {
      if (root.sink?.audio)
        root.sink.audio.muted = !root.sink.audio.muted
    }

    // Scroll = change volume
    onWheel: (wheel) => {
      if (!root.sink?.audio) return

      const step = 0.05
      let vol = root.sink.audio.volume

      if (wheel.angleDelta.y > 0)
        vol = Math.min(1.0, vol + step)
      else
        vol = Math.max(0.0, vol - step)

      root.sink.audio.volume = vol

      // Unmute when scrolling
      if (root.sink.audio.muted)
        root.sink.audio.muted = false
    }
  }
}