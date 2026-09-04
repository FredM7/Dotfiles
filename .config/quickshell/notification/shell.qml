import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Qt5Compat.GraphicalEffects
import QtQuick

ShellRoot {
  NotificationServer {
    id: server
    bodySupported: true
    imageSupported: true

    onNotification: n => {
      n.tracked = true
    }
  }

  PanelWindow {
    // id: win
    // property int hoverCount: 0

    screen: Quickshell.screens.find(s => s.name === "HDMI-A-1") ?? Quickshell.screens[0]

    anchors {
      bottom: true
      right: true
    }
    margins {
      bottom: 16
      right: 16
    }

    implicitWidth: 360
    implicitHeight: list.implicitHeight
    color: "transparent"

    visible: server.trackedNotifications.values.length > 0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
      id: list
      width: 360
      spacing: 8

      HoverHandler {
        id: stackHover
      }

      Repeater {
        model: server.trackedNotifications

        Item {
          required property var modelData

          width: 360
          implicitHeight: card.implicitHeight

          layer.enabled: true
          layer.smooth: true
          layer.effect: OpacityMask {
            maskSource: Rectangle {
              width: card.width
              height: card.height
              radius: card.radius
            }
          }

          Rectangle {
            id: card
            // required property var modelData

            // width: 360
            anchors.fill: parent
            // height: 90
            height: implicitHeight
            implicitHeight: Math.max(80, content.implicitHeight + 25)
            // color: "#1e1e2e"
            radius: 8
            color: "#ee111111"
            border.color: "#44ffffff"
            border.width: 1
            // clip: true

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              // onClicked: modelData.dismiss()
              onClicked: event => {
                if (event.button === Qt.RightButton) {
                  modelData.dismiss()
                  return
                }

                const actions = modelData.actions
                let invoked = false
                for (let i = 0; i < actions.length; i++) {
                  if (actions[i].identifier === "default") {
                    actions[i].invoke()
                    invoked = true
                    break
                  }
                }
                // if (!invoked && actions.length > 0) {
                //   actions[0].invoke()
                //   invoked = true
                // }
                // if (!invoked && modelData.desktopEntry !== "")
                //   Quickshell.execDetached(["gtk-launch", modelData.desktopEntry])

                // modelData.dismiss()
              }
              // onEntered: win.hoverCount++
              // onExited: win.hoverCount--
            }

            Row {
              id: content
              // anchors {
              //   fill: parent
              //   margins: 12
              // }
              anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
              }
              spacing: 12

              Image {
                // anchors.verticalCenter: parent.verticalCenter
                visible: modelData.image !== "" || modelData.appIcon !== ""
                width: 38
                height: 38
                fillMode: Image.PreserveAspectFit
                // source: modelData.image !== "" ? modelData.image : modelData.appIcon
                source: {
                  if (modelData.image !== "")
                    return modelData.image
                  const icon = modelData.appIcon
                  if (icon.startsWith("/") || icon.indexOf("://") !== -1)
                    return icon
                  return Quickshell.iconPath(icon)
                }
              }

              Column {
                // anchors {
                //   fill: parent
                //   margins: 12
                // }
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (parent.children[0].visible ? 60 : 0)
                spacing: 4

                Text {
                  width: parent.width
                  color: "white"
                  font.family: "Noto Sans Serif"
                  font.pixelSize: 16
                  elide: Text.ElideRight
                  text: modelData.summary
                }

                Text {
                  width: parent.width
                  color: "#c0c0c0"
                  font.family: "Noto Sans Serif"
                  font.pixelSize: 14
                  wrapMode: Text.Wrap
                  text: modelData.body
                }
              }
            }

            Timer {
              id: life
              interval: 20
              repeat: true
              running: !stackHover.hovered
              property int elapsed: 0
              readonly property int total: 7000
              onTriggered: {
                elapsed += interval
                if (elapsed >= total)
                  modelData.expire()
              }
            }

            Rectangle {
              anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
              }

              height: 3
              color: "#313244"

              Rectangle {
                height: parent.height
                width: parent.width * Math.max(0, 1 - life.elapsed / life.total)
                color: "#89b4fa"
              }
            }
          }
        }
      }
    }
  }
}