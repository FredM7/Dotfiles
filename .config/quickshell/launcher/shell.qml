import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
  id: root

  property bool launcherOpen: false
  property bool clipboardOpen: false

  property var hiddenIds: ({})
  property var usage: ({})

  readonly property string hiddenPath: `${Quickshell.shellDir}/hidden.json`
  readonly property string usagePath: `${Quickshell.cacheDir}/usage.json` // ~/.cache/quickshell/by-shell/<shell-id>/usage.json
  // readonly property string usagePath: `${Quickshell.shellDir}/usage.json`

  function isHidden(entry) {
    if (!entry)
      return false;
    const id = String(entry.id || "");
    const name = String(entry.name || "").toLowerCase();
    return root.hiddenIds[id] === true || root.hiddenIds[name] === true;
  }

  function setHidden(entry, hide) {
    if (!entry || !entry.id)
      return;
    const next = Object.assign({}, root.hiddenIds);
    if (hide)
      next[entry.id] = true;
    else
      delete next[entry.id];
    root.hiddenIds = next;
    persistHidden();
  }

  function persistHidden() {
    const ids = Object.keys(root.hiddenIds).filter(k => root.hiddenIds[k]);
    ids.sort();
    hiddenFile.setText(JSON.stringify({ ids: ids }, null, 2) + "\n");
  }

  function recordUse(entry) {
    if (!entry || !entry.id)
      return;
    const next = Object.assign({}, root.usage);
    const prev = next[entry.id] || { count: 0, last: 0 };
    next[entry.id] = {
      count: (prev.count || 0) + 1,
      last: Date.now()
    };
    root.usage = next;
    usageFile.setText(JSON.stringify(next, null, 2) + "\n");
  }

  function parseHidden(text) {
    try {
      const data = JSON.parse(text || "{}");
      const map = {};
      const ids = data.ids || data || [];
      if (Array.isArray(ids)) {
        for (let i = 0; i < ids.length; i++)
          map[String(ids[i])] = true;
      } else if (ids && typeof ids === "object") {
        Object.keys(ids).forEach(k => {
          if (ids[k])
            map[k] = true;
        });
      }
      root.hiddenIds = map;
    } catch (e) {
      console.warn("qs-launcher: failed to parse hidden.json:", e);
    }
  }

  function parseUsage(text) {
    try {
      const data = JSON.parse(text || "{}");
      root.usage = data && typeof data === "object" ? data : {};
    } catch (e) {
      root.usage = {};
    }
  }

  function show() {
    root.launcherOpen = true;
    root.clipboardOpen = false;
  }

  function hide() {
    root.launcherOpen = false;
  }

  function toggle() {
    root.launcherOpen = !root.launcherOpen;
  }

  function showClipboard() {
    root.launcherOpen = false;
    root.clipboardOpen = true;
  }

  function hideClipboard() {
    root.clipboardOpen = false;
  }

  function toggleClipboard() {
    root.clipboardOpen = !root.clipboardOpen;
}

  FileView {
    id: hiddenFile
    path: root.hiddenPath
    watchChanges: true
    blockLoading: true
    onLoaded: root.parseHidden(text())
    onFileChanged: reload()
    onLoadFailed: {
      setText("{\n  \"ids\": []\n}\n");
      root.hiddenIds = {};
    }
  }

  FileView {
    id: usageFile
    path: root.usagePath
    watchChanges: true
    blockLoading: true
    onLoaded: root.parseUsage(text())
    onFileChanged: reload()
    onLoadFailed: root.usage = {}
  }

  IpcHandler {
    target: "launcher"

    function toggle(): void {
      root.toggle();
    }
    function show(): void {
        root.show();
    }
    function hide(): void {
      root.hide();
    }
    function isOpen(): bool {
      return root.launcherOpen;
    }
  }

  IpcHandler {
    target: "clipboard"

    function toggle(): void {
      root.toggleClipboard();
    }
    function show(): void {
      root.showClipboard();
    }
    function hide(): void {
      root.hideClipboard();
    }
    function isOpen(): bool {
      return root.clipboardOpen;
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData

      readonly property bool onFocusedScreen: {
        const fm = Hyprland.focusedMonitor;
        if (!fm || !modelData)
          return true;
        return fm.name === modelData.name;
      }

      screen: modelData
      visible: root.launcherOpen && onFocusedScreen
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "qs-launcher"
      WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      onVisibleChanged: {
        if (visible)
          Qt.callLater(() => panel.grabFocus());
      }

      LauncherPanel {
        id: panel
        anchors.fill: parent
        shell: root
        active: win.visible
        onRequestClose: root.hide()
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: clipWin
      required property var modelData

      readonly property bool onFocusedScreen: {
        const fm = Hyprland.focusedMonitor;
        if (!fm || !modelData)
          return true;
        return fm.name === modelData.name;
      }

      screen: modelData
      visible: root.clipboardOpen && onFocusedScreen
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "qs-clipboard"
      WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      anchors { top: true; bottom: true; left: true; right: true }

      onVisibleChanged: {
        if (visible)
          Qt.callLater(() => clipPanel.grabFocus());
      }

      ClipboardPanel {
        id: clipPanel
        anchors.fill: parent
        active: clipWin.visible
        onRequestClose: root.hideClipboard()
      }
    }
  }
}