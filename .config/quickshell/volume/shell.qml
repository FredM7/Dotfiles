import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
  id: root

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  Connections {
    target: Pipewire.defaultAudioSink?.audio
    function onVolumeChanged() {
      root.shouldShowOsd = true
      hideTimer.restart()
    }
  }

  property bool shouldShowOsd: false

  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: root.shouldShowOsd = false
  }

  LazyLoader {
    active: root.shouldShowOsd

    PanelWindow {
      anchors.bottom: true
      margins.bottom: 20
      exclusiveZone: 0
      implicitWidth: 400
      implicitHeight: 40
      color: "transparent"
      mask: Region {}

      Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#80000000"

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 14
          spacing: 10

          // IconImage {
          //   implicitSize: 28
          //   source: {
          //     const audio = Pipewire.defaultAudioSink?.audio
          //     if (!audio || audio.muted || audio.volume <= 0)
          //         return Quickshell.iconPath("audio-volume-muted-symbolic")
          //     if (audio.volume < 0.33)
          //         return Quickshell.iconPath("audio-volume-low-symbolic")
          //     if (audio.volume < 0.66)
          //         return Quickshell.iconPath("audio-volume-medium-symbolic")
          //     return Quickshell.iconPath("audio-volume-high-symbolic")
          //   }
          // }

          Item {
            Layout.fillWidth: true
            implicitHeight: 14

            // track
            Rectangle {
              anchors.fill: parent
              radius: height / 2
              color: "#50ffffff"
            }

            // fill
            Rectangle {
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              width: parent.width * Math.max(0, Math.min(1, Pipewire.defaultAudioSink?.audio.volume ?? 0))
              radius: parent.height / 2
              color: (Pipewire.defaultAudioSink?.audio.muted ?? false) ? "#80ffffff" : "#ffffffff"
            }

            // percentage on the bar
            Text {
              font.family: "Noto Sans Serif"
              anchors.centerIn: parent
              text: {
                const audio = Pipewire.defaultAudioSink?.audio
                if (!audio || audio.muted)
                  return "MUTE"
                return Math.round((audio.volume ?? 0) * 100) + "%"
              }
              // color: "#111111"
              color: {
                const audio = Pipewire.defaultAudioSink?.audio
                if (!audio || audio.muted)
                  return "white"
                return (audio.volume ?? 0) <= 0.45 ? "white" : "#111111"
              }
              font.pixelSize: 12
              // font.bold: true
              // style: Text.Outline
              // styleColor: "#80ffffff"
            }
          }
        }

        // RowLayout {
        //   anchors.fill: parent
        //   anchors.leftMargin: 10
        //   anchors.rightMargin: 15

        //   // IconImage {
        //   //     implicitSize: 30
        //   //     source: Quickshell.iconPath("audio-volume-high-symbolic")
        //   // }

        //   Rectangle {
        //     Layout.fillWidth: true
        //     implicitHeight: 10
        //     radius: 20
        //     color: "#50ffffff"

        //     Rectangle {
        //       anchors.left: parent.left
        //       anchors.top: parent.top
        //       anchors.bottom: parent.bottom
        //       implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
        //       radius: parent.radius
        //     }
        //   }
        // }
      }
    }
  }
}