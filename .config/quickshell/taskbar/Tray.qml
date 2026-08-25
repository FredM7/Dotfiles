import Quickshell.Services.SystemTray
import QtQuick
// import QtQuick.Controls
import Quickshell

Row {
  // required property var tooltip
  // required property var bar

  id: trayRow
  spacing: 6
  anchors.verticalCenter: parent.verticalCenter

  // Tooltip {
  //   id: tip
  // }
  Tooltip {
    id: tip
  }

  Repeater {
    model: SystemTray.items

    Image {
      required property var modelData
      id: icon

      source: modelData.icon
      width: 18
      height: 18
      sourceSize.width: 18
      sourceSize.height: 18
      fillMode: Image.PreserveAspectFit

      QsMenuAnchor {
        id: menuAnchor
        menu: modelData.menu
        anchor.item: icon
        anchor.edges: Edges.Bottom | Edges.HorizontalCenter
        anchor.gravity: Edges.Bottom | Edges.HorizontalCenter
        anchor.margins.top: 28
      }

      MouseArea {
        id: ma
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: (mouse) => {
          if (mouse.button === Qt.LeftButton) {
            modelData.activate()
          }
          
          if (mouse.button === Qt.RightButton) {
            // modelData.display(Window.window, 0, icon.height)
            menuAnchor.open()
          }
        }

        // onEntered: {
        //   if (modelData.tooltipTitle && modelData.tooltipTitle !== "")
        //     tooltip.text = modelData.tooltipTitle
        //   else if (modelData.title && modelData.title !== "")
        //     tooltip.text = modelData.title
        //   else
        //     tooltip.text = modelData.id

        //   // Position the popup under the icon
        //   // const pos = mapToItem(trayRow, 0, height + 6)
        //   const pos = mapToItem(bar, width / 2, height + 8)
        //   // tooltip.x = pos.x + (width - tooltip.width) / 2
        //   tooltip.x = pos.x - tooltip.width / 2
        //   tooltip.y = pos.y
        //   tooltip.open()
        // }

        // onExited: tooltip.close()

        onEntered: {
          // console.log("Mouse entered tray icon: " + modelData.icon)
          if (modelData.tooltipTitle && modelData.tooltipTitle !== "")
            tip.text = modelData.tooltipTitle
          else if (modelData.title && modelData.title !== "")
            tip.text = modelData.title
          else
            tip.text = modelData.id

          tip.target = icon          // tell the popup which item to anchor to
          tip.show = true
        }

        onExited: {
          // tip.target = null
          // tip.text = ""
          tip.show = false
        }
      }

      // ToolTip.visible: hoverHandler.hovered
      // ToolTip.text: "This is a Quickshell tooltip!"

      // ToolTip.visible: ma.containsMouse
      // ToolTip.delay: 400
      // ToolTip.text: {
      //   if (modelData.tooltipTitle && modelData.tooltipTitle !== "")
      //     return modelData.tooltipTitle
      //   if (modelData.title && modelData.title !== "")
      //     return modelData.title
      //   return modelData.id
      // }

      // Popup {
      //   id: tip
      //   y: parent.height + 6
      //   x: (parent.width - width) / 2
      //   padding: 6
      //   closePolicy: Popup.NoAutoClose

      //   background: Rectangle {
      //     color: "#1e1e2e"
      //     radius: 6
      //     border.color: "#45475a"
      //     border.width: 1
      //   }

      //   contentItem: Text {
      //     text: {
      //       if (modelData.tooltipTitle && modelData.tooltipTitle !== "")
      //         return modelData.tooltipTitle
      //       if (modelData.title && modelData.title !== "")
      //         return modelData.title
      //       return modelData.id
      //     }
      //     color: "#cdd6f4"
      //     font.pixelSize: 12
      //   }
      // }

      // Rectangle {
      //   visible: ma.containsMouse
      //   anchors.horizontalCenter: parent.horizontalCenter
      //   anchors.top: parent.bottom
      //   anchors.topMargin: 6
      //   z: 999

      //   width: tipText.implicitWidth + 12
      //   height: tipText.implicitHeight + 8
      //   radius: 6
      //   color: "#1e1e2e"
      //   border.color: "#45475a"
      //   border.width: 1

      //   Text {
      //     id: tipText
      //     anchors.centerIn: parent
      //     color: "#cdd6f4"
      //     font.pixelSize: 12
      //     text: {
      //       if (modelData.tooltipTitle && modelData.tooltipTitle !== "")
      //         return modelData.tooltipTitle
      //       if (modelData.title && modelData.title !== "")
      //         return modelData.title
      //       return modelData.id
      //     }
      //   }
      // }
    }
  }
}