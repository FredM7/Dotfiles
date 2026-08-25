import Quickshell
import Quickshell.Io
import QtQuick

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
          spacing: 10

          // ─── Left buttons ───────────────────────────────
          Row {
            spacing: 6

            // 1. App launcher (dmenu / rofi / wofi)
            Rectangle {
              width: 34
              height: 30
              radius: 6
              color: launcherMa.containsMouse ? "#45475a" : "#313244"

              Text {
                anchors.centerIn: parent
                text: "󰣇"          // or "󰕰" / "" — change to whatever you like
                color: "#cdd6f4"
                font.pixelSize: 25
              }

              MouseArea {
                id: launcherMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])
                // Alternatives:
                // Quickshell.execDetached(["wofi", "--show", "drun"])
                // Quickshell.execDetached(["fuzzel"])
                // Quickshell.execDetached(["dmenu_run"])
              }
            }

            // 2. btop
            Rectangle {
              width: 34
              height: 30
              radius: 6
              color: btopMa.containsMouse ? "#45475a" : "#313244"

              Text {
                anchors.centerIn: parent
                text: "󰨇"          // or ""
                color: "#cdd6f4"
                font.pixelSize: 20
              }

              MouseArea {
                id: btopMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["ghostty", "-e", "btop"])
                // Change "kitty" to your terminal if different (foot, alacritty, etc.)
              }
            }

            // 3. hyprpicker
            Rectangle {
              width: 34
              height: 30
              radius: 6
              color: pickerMa.containsMouse ? "#45475a" : "#313244"

              Text {
                anchors.centerIn: parent
                text: "󰈋"          // or ""
                color: "#cdd6f4"
                font.pixelSize: 23
              }

              MouseArea {
                id: pickerMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["hyprpicker"])
              }
            }
          }

          Item {
            width: 20   // change this number for more/less space
            height: 1
          }

          Hypr {
            // anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            screen: modelData
          }
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 12
          anchors.verticalCenter: parent.verticalCenter
          spacing: 10

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

          Time {}
        }
      }
    }
  }
}