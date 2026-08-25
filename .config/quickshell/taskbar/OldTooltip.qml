import QtQuick
import QtQuick.Controls

Popup {
  id: root
  padding: 6
  closePolicy: Popup.NoAutoClose
  modal: false
  focus: false

  property string text: ""

  background: Rectangle {
    color: '#b4236e'
    radius: 6
    border.color: "#45475a"
    border.width: 1
  }

  contentItem: Text {
    text: root.text
    color: "#cdd6f4"
    font.pixelSize: 12
  }
}