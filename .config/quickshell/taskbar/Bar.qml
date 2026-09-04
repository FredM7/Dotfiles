import Quickshell
import Quickshell.Io
import QtQuick
import "TimeCalendar" as TimeCalendar
import "Grok" as Grok
import "Spotify" as Spotify

Scope {
  // id: root
  // property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      id: barWindow
      screen: modelData

      color: "#aa000000"

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

      // Tooltip {
      //   id: globalTip
      // }

      Item {
        id: barContent
        anchors.fill: parent

        // Main content row
        Row {
          anchors.left: parent.left
          anchors.leftMargin: 12
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          // ─── Left buttons ───────────────────────────────
          Row {
            spacing: 5

            Launcher {}

            Activities {}

            Hyprpick {}
          }

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          Workspaces {
            // anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            screen: modelData
          }

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          Spotify.Player {
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 12
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Cpu {}

          Ram {}
          
          Disk {}
          
          Volume {}

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          Tray {
            // tooltip: globalTip
            // bar: barContent
          }

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          Grok.Button {
            anchors.verticalCenter: parent.verticalCenter
          }

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          TimeCalendar.Time {}
        }
      }
    }
  }
}