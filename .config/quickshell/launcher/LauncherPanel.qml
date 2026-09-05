import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
  id: panel

  required property var shell
  property bool active: false

  signal requestClose()

  property string query: ""
  property int sel: 0
  property bool showHidden: false
  readonly property bool commandMode: query.trim().startsWith("!") || query.trim().startsWith(">")

  readonly property color bg: "#12141a"
  readonly property color surface: "#1b1e27"
  readonly property color surfaceHi: "#252833"
  readonly property color border: "#343845"
  readonly property color text: "#e8e6e1"
  readonly property color muted: "#8b909d"
  readonly property color accent: "#e0a35c"
  readonly property color danger: "#d4776b"
  readonly property color dim: "#00000099"

  readonly property var results: {
    const q = panel.query.trim();

    if (panel.commandMode)
      return [];

    const vals = DesktopEntries.applications.values || [];
    const all = [];
    for (let i = 0; i < vals.length; i++) {
      const e = vals[i];
      if (!e || !e.name)
        continue;
      const hidden = shell.isHidden(e);
      if (panel.showHidden ? !hidden : hidden)
        continue;
      all.push(e);
    }

    const needle = q.toLowerCase();
    let list;
    if (!needle) {
      list = all.slice();
    } else {
      const scored = [];
      for (let i = 0; i < all.length; i++) {
        const e = all[i];
        const s = scoreEntry(e, needle);
        if (s >= 0)
          scored.push({ e: e, s: s });
      }
      scored.sort((a, b) => {
        if (a.s !== b.s)
          return a.s - b.s;
        return String(a.e.name).localeCompare(String(b.e.name));
      });
      list = scored.map(x => x.e);
    }

    if (!needle) {
      list.sort((a, b) => {
        const ua = usageOf(a);
        const ub = usageOf(b);
        if (ua.last !== ub.last)
          return ub.last - ua.last;
        if (ua.count !== ub.count)
          return ub.count - ua.count;
        return String(a.name).localeCompare(String(b.name));
      });
    }

    return list;
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
      showHidden = false;
      input.text = "";
      grabFocus();
    }
  }

  function usageOf(entry) {
    const rec = shell.usage[entry.id] || {};
    return { count: rec.count || 0, last: rec.last || 0 };
  }

  function scoreEntry(entry, q) {
    const name = String(entry.name || "").toLowerCase();
    const gen = String(entry.genericName || "").toLowerCase();
    const com = String(entry.comment || "").toLowerCase();
    const id = String(entry.id || "").toLowerCase();
    const kw = (entry.keywords || []).join(" ").toLowerCase();
    const cat = (entry.categories || []).join(" ").toLowerCase();

    if (name === q)
      return 0;
    if (name.startsWith(q))
      return 1;
    if (id.startsWith(q) || id === q)
      return 2;
    if (name.indexOf(q) >= 0)
      return 3;
    if (gen.startsWith(q) || gen.indexOf(q) >= 0)
      return 4;
    if (kw.indexOf(q) >= 0)
      return 5;
    if (com.indexOf(q) >= 0 || cat.indexOf(q) >= 0)
      return 6;
    return -1;
  }

  function grabFocus() {
    input.forceActiveFocus();
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

  function launchSelected() {
    if (commandMode) {
      const raw = query.replace(/^[!>]\s*/, "").trim();
      if (raw.length)
        Quickshell.execDetached(["sh", "-c", raw]);
      close();
      return;
    }
    if (sel < 0 || sel >= results.length)
      return;
    launch(results[sel]);
  }

  function launch(entry) {
    if (!entry)
      return;
    shell.recordUse(entry);
    entry.execute();
    close();
  }

  function toggleHiddenSelected() {
    if (sel < 0 || sel >= results.length)
      return;
    const entry = results[sel];
    const hide = !shell.isHidden(entry);
    shell.setHidden(entry, hide);
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
            text: panel.commandMode ? "!" : (panel.showHidden ? "◌" : "⌕")
            color: panel.commandMode ? panel.danger : panel.accent
            font.pixelSize: 18
          }

          TextInput {
            id: input
            Layout.fillWidth: true
            color: panel.text
            font.pixelSize: 16
            font.family: "Inter, JetBrains Mono, sans-serif"
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
                panel.launchSelected();
                event.accepted = true;
              } else if (event.key === Qt.Key_H && (event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)) {
                panel.toggleHiddenSelected();
                event.accepted = true;
              } else if (event.key === Qt.Key_H && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                panel.showHidden = !panel.showHidden;
                panel.sel = 0;
                event.accepted = true;
              } else if (event.key === Qt.Key_Tab) {
                panel.showHidden = !panel.showHidden;
                panel.sel = 0;
                event.accepted = true;
              }
            }
          }
        }

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 42
          anchors.verticalCenter: parent.verticalCenter
          text: panel.showHidden ? "hidden apps  ·  tab to go back" : "search apps  ·  prefix ! to run a command"
          color: panel.muted
          font.pixelSize: 14
          visible: input.text === ""
          enabled: false
          z: 0
        }
      }

      Text {
        visible: panel.showHidden
        text: "Showing hidden apps. Ctrl+H unhides the selected one."
        color: panel.danger
        font.pixelSize: 12
        Layout.fillWidth: true
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
            anchors.leftMargin: 10
            anchors.rightMargin: 12
            spacing: 12

            Rectangle {
              width: 34
              height: 34
              radius: 8
              color: panel.surface
              border.width: 1
              border.color: panel.border

              Image {
                anchors.centerIn: parent
                width: 22
                height: 22
                fillMode: Image.PreserveAspectFit
                source: {
                  if (!modelData || !modelData.icon)
                    return "";
                  return Quickshell.iconPath(modelData.icon, true) || "";
                }
                visible: source !== ""
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 1

              Text {
                Layout.fillWidth: true
                text: modelData.name || ""
                color: panel.text
                font.pixelSize: 14
                elide: Text.ElideRight
              }

              Text {
                Layout.fillWidth: true
                text: modelData.comment || modelData.genericName || modelData.id || ""
                color: panel.muted
                font.pixelSize: 11
                elide: Text.ElideRight
                visible: text !== ""
              }
            }

            Text {
              visible: panel.showHidden
              text: "hidden"
              color: panel.danger
              font.pixelSize: 11
            }

            MouseArea {
              Layout.preferredWidth: 28
              Layout.preferredHeight: 28
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              onClicked: {
                panel.sel = index;
                panel.toggleHiddenSelected();
              }

              Text {
                anchors.centerIn: parent
                text: panel.showHidden ? "↩" : "✕"
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
            onClicked: panel.launch(modelData)
          }
        }

        Text {
          anchors.centerIn: parent
          visible: list.count === 0 && !panel.commandMode
          text: panel.showHidden ? "no hidden apps" : "no matching apps"
          color: panel.muted
          font.pixelSize: 14
        }

        Rectangle {
          visible: panel.commandMode
          anchors.fill: parent
          color: "transparent"

          Column {
            anchors.centerIn: parent
            spacing: 6
            width: parent.width - 24

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "run command"
              color: panel.muted
              font.pixelSize: 12
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: panel.query.replace(/^[!>]\s*/, "")
              color: panel.accent
              font.pixelSize: 16
              elide: Text.ElideMiddle
              wrapMode: Text.Wrap
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 28
        color: "transparent"

        RowLayout {
          anchors.fill: parent
          spacing: 12

          Text {
            text: panel.commandMode
              ? "enter run   esc close"
              : "↵ launch   ctrl+h hide   tab hidden   ↑↓ move   ! cmd"
            color: panel.muted
            font.pixelSize: 11
            Layout.fillWidth: true
            elide: Text.ElideRight
          }

          Text {
            text: panel.commandMode ? "" : `${list.count}`
            color: panel.muted
            font.pixelSize: 11
          }
        }
      }
    }
  }
}