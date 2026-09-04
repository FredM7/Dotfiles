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

    Text {
      anchors.verticalCenter: parent.verticalCenter
      color: "white"
      font.pixelSize: 18
      text: "󰒮"
      visible: player && player.canGoPrevious
      MouseArea { anchors.fill: parent; onClicked: player.previous() }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      color: "white"
      font.pixelSize: 18
      text: player && player.isPlaying ? "󰏤" : "󰐊"
      visible: player && player.canTogglePlaying
      
      MouseArea { anchors.fill: parent; onClicked: player.togglePlaying() }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      color: "white"
      font.pixelSize: 18
      text: "󰒭"
      visible: player && player.canGoNext

      MouseArea { anchors.fill: parent; onClicked: player.next() }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      font.family: "Noto Sans Serif"
      font.pixelSize: 14
      color: "white"
      text: player
        ? (player.trackArtist ? player.trackArtist + " — " : "")
          + (player.trackTitle || player.identity)
        : ""
    }
  }
}

// import QtQuick
// import QtQuick.Layouts
// import Quickshell.Services.Mpris

// RowLayout {
//     id: root
//     spacing: 8

//     readonly property var players: Mpris.players.values
//     readonly property var player: {
//         for (let i = 0; i < players.length; i++) {
//             const p = players[i]
//             const name = ((p.identity || "") + " " + (p.dbusName || "")).toLowerCase()
//             if (name.includes("spotify"))
//                 return p
//         }
//         return players.length ? players[0] : null
//     }

//     visible: player !== null

    
//     Rectangle {
//       // width: 
//       height: 30
//       radius: 6
//       // color: pickerMa.containsMouse ? "#ffffff" : "transparent"
//       // border: {
//       //   width: 1
//       //   color: "#1ed760"
//       // }
//       color: "#1ed760"
//       border.width: 1
//       border.color: "#1ed760" 

//       Row {
//         id: content
//         anchors.verticalCenter: parent.verticalCenter
//         anchors.left: parent.left
//         anchors.leftMargin: root.pad
//         spacing: 8

//         Text {
//           font.family: "Noto Sans Serif"
//           font.pixelSize: 14
//           color: "white"
//             text: player
//               ? (player.trackArtist ? player.trackArtist + " — " : "") + (player.trackTitle || player.identity)
//               : ""
//             elide: Text.ElideRight
//             Layout.maximumWidth: 240
//         }

//         Text {
//           color: "white"
//           text: "󰒮"
//           font.pixelSize: 14
//           visible: player && player.canGoPrevious
//           MouseArea { anchors.fill: parent; onClicked: player.previous() }
//         }
//         Text {
//           color: "white"
//           font.pixelSize: 14
//           text: player && player.isPlaying ? "󰏤" : "󰐊"
//           visible: player && player.canTogglePlaying
//           MouseArea { anchors.fill: parent; onClicked: player.togglePlaying() }
//         }
//         Text {
//           color: "white"
//           font.pixelSize: 14
//           text: "󰒭"
//           visible: player && player.canGoNext
//           MouseArea { anchors.fill: parent; onClicked: player.next() }
//         }
//       }
//     }
// }
