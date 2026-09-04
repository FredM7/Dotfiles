import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Rectangle {
  id: root
  visible: player !== null
  height: 30
  radius: 6
  color: "transparent"
  border.color: "#1ed760"
  readonly property int buttonSize: 18

  readonly property int pad: 10
  width: content.implicitWidth + pad * 2

  readonly property var players: Mpris.players.values
  readonly property var player: {
    const list = players
    for (let i = 0; i < list.length; i++) {
      const p = list[i]
      const name = ((p.identity || "") + " " + (p.dbusName || "")).toLowerCase()
      if (name.includes("spotify"))
        return p
    }
    return list.length ? list[0] : null
  }

  Row {
    id: content
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.pad
    spacing: 8

    Icon {
      iconColor: '#1ed760'
    }

    Row {
      id: buttons
      spacing: 3
      anchors.verticalCenter: parent.verticalCenter


      Rectangle {
        width: root.buttonSize
        height: root.buttonSize
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          color: "white"
          font.pixelSize: root.buttonSize + 4
          text: "󰒮"
          visible: player && player.canGoPrevious

          MouseArea {
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: player.previous()
          }
        }
      }

      Rectangle {
        width: root.buttonSize
        height: root.buttonSize
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          color: "white"
          font.pixelSize: root.buttonSize
          text: player && player.isPlaying ? "" : ""
          visible: player && player.canTogglePlaying

          MouseArea {
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: player.togglePlaying()
          }
        }
      }

      Rectangle {
        width: root.buttonSize
        height: root.buttonSize
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          color: "white"
          font.pixelSize: root.buttonSize + 4
          text: "󰒭"
          visible: player && player.canGoNext

          MouseArea {
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: player.next()
          }
        }
      }
    }

    Rectangle {
      width: 1
      height: root.height
      color: root.border.color
    }

    Item {
      id: trackBox
      width: title.width
      height: title.height
      anchors.verticalCenter: parent.verticalCenter

      Text {
        id: title
        font.family: "Noto Sans Serif"
        font.pixelSize: 14
        color: "white"
        text: player
          ? (player.trackArtist ? player.trackArtist + " — " : "")
            + (player.trackTitle || player.identity)
          : ""
      }

      Seek {
        anchors.left: title.left
        anchors.right: title.right
        anchors.top: title.bottom
        anchors.topMargin: 6
        player: root.player
        barColor: root.border.color
      }
    }

  }
}
