import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
  id: root
  spacing: 6

  required property var screen

  // ──────────────────────────────────────────────
  // Configure your ranges here by monitor name
  // ──────────────────────────────────────────────
  readonly property var workspaceRanges: ({
    "HDMI-A-1": { start: 1, end: 5 },   // left monitor → 1-5
    "HDMI-A-2": { start: 6, end: 10 },  // right monitor → 6-10
  })

  readonly property var range: workspaceRanges[screen.name] || { start: 1, end: 5 }
  readonly property int startId: range.start
  readonly property int count: range.end - range.start + 1

  Repeater {
    model: root.count

    Rectangle {
      required property int index

      readonly property int wsId: root.startId + index

      // Find the real workspace object (null if it doesn't exist yet)
      readonly property var ws: {
        const list = Hyprland.workspaces.values
        for (let i = 0; i < list.length; i++) {
          if (list[i].id === wsId)
            return list[i]
        }
        return null
      }

      readonly property bool isFocused: Hyprland.focusedWorkspace?.id === wsId
      readonly property bool isOccupied: ws !== null && ws.toplevels.count > 0

      width: 28
      height: 30
      radius: 6

      color: {
        if (isFocused) return "#89b4fa"
        if (isOccupied) return "#45475a"
        return "#313244"
      }

      Text {
        anchors.centerIn: parent
        text: wsId
        color: isFocused ? "#1e1e2e" : "#cdd6f4"
        font.pixelSize: 14
        font.bold: isFocused
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // onClicked: Hyprland.dispatch("workspace " + wsId)
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsId}" })`)
      }
    }
  }
}

// import Quickshell
// import Quickshell.Hyprland
// import QtQuick.Layouts
// import QtQuick

// Row {
//   id: root

//   required property var screen

//   readonly property var workspaceRanges: ({
//     "HDMI-A-1": { start: 1, end: 5 },
//     "HDMI-A-2": { start: 6, end: 10 },
//   })

//   readonly property var range: workspaceRanges[screen.name]
//   readonly property int startId: range.start
//   readonly property int count: range.end - range.start + 1

//   anchors.centerIn: parent
//   spacing: 6

//   Repeater {
//     // model: Hyprland.workspaces
//     model: root.count

//     // Each workspace button
//     Rectangle {
//       required property var modelData   // this is a HyprlandWorkspace

//       width: 28
//       height: 22
//       radius: 6

//       required property int index
//       // readonly property int wsId: range.start + index
//       readonly property int wsId: root.startId + index

//       readonly property var ws: {
//       console.log("index:", index, "modelData:", modelData)
//         const list = Hyprland.workspaces.values
//         for (let i = 0; i < list.length; i++) {
//           // console.log("Hyprland.workspaces.values:", list[i])
//           if (list[i].id === wsId)
//             return list[i]
//         }
//         return null
//       }

//       // Colors:
//       // - focused  → bright blue
//       // - has windows → slightly lighter
//       // - empty    → darker
//       color: {
//         if (modelData.focused)
//           return "#89b4fa"
//         if (modelData.toplevels.count > 0)
//           return "#45475a"
//         return "#313244"
//       }

//       // Workspace number
//       Text {
//         anchors.centerIn: parent
//         // text: modelData.id
//         text: wsId
//         color: modelData.focused ? "#1e1e2e" : "#cdd6f4"
//         font.pixelSize: 13
//         font.bold: modelData.focused
//       }

//       // Click to switch
//       MouseArea {
//         anchors.fill: parent
//         cursorShape: Qt.PointingHandCursor
//         // onClicked: modelData.activate()   // or Hyprland.dispatch("workspace " + modelData.id)
//         onClicked: Hyprland.dispatch("workspace " + wsId)
//       }
//     }
//   }

//   Component.onCompleted: {
//     console.log("=== Screen object ===")
//     console.log("screen:", screen)
//     console.log("name:", screen.name)
//     console.log("width:", screen.width)
//     console.log("height:", screen.height)
//     console.log("index in Quickshell.screens:", Quickshell.screens.indexOf(screen))

//     // List all screens
//     console.log("--- All screens ---")
//     for (let i = 0; i < Quickshell.screens.length; i++) {
//       const s = Quickshell.screens[i]
//       console.log(i, "→", s.name, s.width + "x" + s.height)
//     }
//   }
// }
