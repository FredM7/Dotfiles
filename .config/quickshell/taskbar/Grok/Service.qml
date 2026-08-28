pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property real usedPercent: -1
  property string resetAt: ""
  property string statusText: "loading…"
  property string lastError: ""

  readonly property string home: Quickshell.env("HOME")
  readonly property string fetchScript: home + "/.config/quickshell/taskbar/Grok/fetch.js"
  readonly property string bunBin: home + "/.bun/bin/bun"

  function refresh() {
    fetchProc.running = false;
    fetchProc.running = true;
  }

  function applyJson(text) {
    const raw = String(text).trim();
    if (!raw.length) {
      root.lastError = "empty output from bun";
      root.statusText = "unavailable";
      return;
    }

    try {
      const d = JSON.parse(raw);
      if (d.error) {
        root.lastError = String(d.error);
        root.statusText = "unavailable";
        root.usedPercent = -1;
        return;
      }

      const cfg = d.config || d;
      const pct = cfg.creditUsagePercent;
      root.usedPercent = pct === undefined ? -1 : Number(pct);

      // const end = cfg.currentPeriod?.end
      //           || cfg.billingPeriodEnd
      //           || "";
      // root.resetAt = end
      //     ? String(end).replace("T", " ").replace(/\.\d+Z$/, " UTC").replace("Z", " UTC")
      //     : "";
      const end = cfg.currentPeriod?.end || cfg.billingPeriodEnd || "";
      root.resetAt = end ? formatReset(end) : "";

      root.lastError = "";
      root.statusText = root.usedPercent < 0 ? "no data" : "ok";
    } catch (e) {
      root.lastError = "parse failed: " + raw.slice(0, 160);
      root.statusText = "error";
    }
  }

  function formatReset(iso) {
    const d = new Date(iso);
    if (isNaN(d.getTime()))
      return String(iso);

    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const pad = (n) => String(n).padStart(2, "0");

    return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()]
      + " " + pad(d.getHours()) + ":" + pad(d.getMinutes());
  }

  Process {
    id: fetchProc
    running: true
    command: ["bash", "-lc", "exec '" + root.bunBin + "' '" + root.fetchScript + "'"]

    stdout: StdioCollector {
      onStreamFinished: root.applyJson(this.text)
    }

    stderr: StdioCollector {
      onStreamFinished: {
        const err = String(this.text).trim();
        if (err.length)
          root.lastError = err.slice(0, 200);
      }
    }
  }

  Timer {
    interval: 5 * 60 * 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}