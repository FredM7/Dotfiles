import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
  id: panel

  property bool active: false
  signal requestClose()

  property string query: ""
  property int sel: 0
  property var entries: []

  readonly property color bg: "#12141a"
  readonly property color surface: "#1b1e27"
  readonly property color surfaceHi: "#252833"
  readonly property color border: "#343845"
  readonly property color text: "#e8e6e1"
  readonly property color muted: "#8b909d"
  readonly property color accent: "#7cb8a6"
  readonly property color danger: "#d4776b"
  readonly property color dim: "#00000099"

  readonly property var results: {
    const q = query.trim().toLowerCase();
    if (!q)
      return entries;
    return entries.filter(e => (e.preview || "").toLowerCase().indexOf(q) >= 0);
  }

  onResultsChanged: {
    if (sel >= results.length)
      sel = Math.max(0, results.length - 1);
    if (results.length && sel < 0)
      sel = 0;
    list.positionViewAtIndex(sel, ListView.Contain);
  }

  onActiveChanged: {
    if (active) {
      query = "";
      sel = 0;
      input.text = "";
      refresh();
      grabFocus();
    }
  }

  function grabFocus() {
    input.forceActiveFocus();
  }

  function refresh() {
    if (listProc.running)
      listProc.running = false;
    listProc.running = true;
  }

  function parseList(raw) {
    const lines = String(raw || "").split("\n");
    const out = [];
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (!line || !line.trim())
        continue;
      const tab = line.indexOf("\t");
      const id = tab >= 0 ? line.slice(0, tab) : line;
      const preview = tab >= 0 ? line.slice(tab + 1) : line;
      const isImage = preview.indexOf("[[ binary data") >= 0;
      out.push({
        id: id,
        raw: line,
        preview: preview,
        isImage: isImage
      });
    }
    entries = out;
    sel = 0;
  }

  function move(delta) {
    const n = results.length;
    if (n === 0)
      return;
    sel = (sel + delta % n + n) % n;
    list.positionViewAtIndex(sel, ListView.Contain);
  }

  function close() {
    requestClose();
  }

  function copySelected() {
    if (sel < 0 || sel >= results.length)
      return;
    copyEntry(results[sel]);
  }

  function copyEntry(entry) {
    if (!entry)
      return;
    Quickshell.execDetached([
      "sh", "-c",
      "printf '%s\\n' \"$1\" | cliphist decode | wl-copy",
      "_",
      entry.raw
    ]);
    close();
  }

  function deleteSelected() {
    if (sel < 0 || sel >= results.length)
      return;
    const entry = results[sel];
    Quickshell.execDetached([
      "sh", "-c",
      "printf '%s\\n' \"$1\" | cliphist delete",
      "_",
      entry.raw
    ]);
    entries = entries.filter(e => e.raw !== entry.raw);
  }

  Process {
    id: listProc
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: panel.parseList(text)
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: panel.close()
  }

  Rectangle {
    anchors.fill: parent
    color: panel.dim
  }

  Rectangle {
    id: card
    anchors.centerIn: parent
    width: Math.min(680, panel.width - 48)
    height: Math.min(520, panel.height - 80)
    radius: 16
    color: panel.bg
    border.width: 1
    border.color: panel.border

    MouseArea {
      anchors.fill: parent
      onClicked: panel.grabFocus()
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 10

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 48
        radius: 10
        color: panel.surface
        border.width: 1
        border.color: input.activeFocus ? panel.accent : panel.border

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 12
          spacing: 10

          Text {
            text: "⎘"
            color: panel.accent
            font.pixelSize: 16
          }

          TextInput {
            id: input
            Layout.fillWidth: true
            color: panel.text
            font.pixelSize: 16
            selectByMouse: true
            selectionColor: panel.accent
            selectedTextColor: panel.bg
            clip: true
            focus: true
            onTextChanged: panel.query = text

            Keys.onPressed: event => {
              if (event.key === Qt.Key_Escape) {
                panel.close();
                event.accepted = true;
              } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier))) {
                panel.move(1);
                event.accepted = true;
              } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier))) {
                panel.move(-1);
                event.accepted = true;
              } else if (event.key === Qt.Key_PageDown) {
                panel.move(8);
                event.accepted = true;
              } else if (event.key === Qt.Key_PageUp) {
                panel.move(-8);
                event.accepted = true;
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                panel.copySelected();
                event.accepted = true;
              } else if (event.key === Qt.Key_Delete || (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier))) {
                panel.deleteSelected();
                event.accepted = true;
              }
            }
          }
        }

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 42
          anchors.verticalCenter: parent.verticalCenter
          text: "search clipboard history"
          color: panel.muted
          font.pixelSize: 14
          visible: input.text === ""
          enabled: false
        }
      }

      ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 2
        model: panel.results
        currentIndex: panel.sel
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
          required property int index
          required property var modelData

          width: list.width
          height: 54
          radius: 10
          color: index === panel.sel ? panel.surfaceHi : "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            Text {
              text: modelData.isImage ? "🖼" : "T"
              color: panel.accent
              font.pixelSize: 13
              Layout.preferredWidth: 18
            }

            Text {
              Layout.fillWidth: true
              text: modelData.preview || ""
              color: panel.text
              font.pixelSize: 13
              elide: Text.ElideRight
              maximumLineCount: 2
              wrapMode: Text.NoWrap
            }

            MouseArea {
              Layout.preferredWidth: 28
              Layout.preferredHeight: 28
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              onClicked: {
                panel.sel = index;
                panel.deleteSelected();
              }

              Text {
                anchors.centerIn: parent
                text: "✕"
                color: parent.containsMouse ? panel.danger : panel.muted
                font.pixelSize: 13
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            anchors.rightMargin: 36
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: panel.sel = index
            onClicked: panel.copyEntry(modelData)
          }
        }

        Text {
          anchors.centerIn: parent
          visible: list.count === 0
          text: panel.entries.length === 0 ? "clipboard history is empty" : "no matches"
          color: panel.muted
          font.pixelSize: 14
        }
      }

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "↵ copy   del remove   esc close"
          color: panel.muted
          font.pixelSize: 11
          Layout.fillWidth: true
        }

        Text {
          text: `${list.count}`
          color: panel.muted
          font.pixelSize: 11
        }
      }
    }
  }
}