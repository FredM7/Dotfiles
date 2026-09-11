pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// One poller for the whole shell. Bar buttons only bind to this.
Scope {
    id: root

    property var prs: []
    property int count: 0
    property string login: ""
    property string teamSlug: "doshexchange/reviewers"
    property string status: "idle"   // idle | loading | error | ok
    property string errorText: ""
    property bool ready: false
    property string lastUpdated: ""
    property int refreshMs: 5 * 60 * 1000
    property int limit: 50

    readonly property string countLabel: count > 99 ? "99+" : (count > 0 ? ("" + count) : "")
    readonly property string inboxUrl: "https://github.com/pulls/review-requested"

    function scriptPath() {
        return String(Qt.resolvedUrl("fetch.sh")).replace(/^file:\/\//, "");
    }

    function refresh() {
        if (fetchProc.running)
            return;
        status = "loading";
        errorText = "";
        fetchProc.command = [
            "bash", root.scriptPath()
        ];
        fetchProc.environment = ({
            GH_PAGER: "cat",
            GH_REVIEW_TEAM: root.teamSlug,
            GH_REVIEW_LIMIT: String(root.limit)
        });
        fetchProc.running = true;
    }

    function openUrl(url) {
        if (!url)
            return;
        Quickshell.execDetached(["xdg-open", url]);
    }

    function openInbox() {
        openUrl(root.inboxUrl);
    }

    function clockTime(date) {
        const d = date || new Date();
        const pad = n => (n < 10 ? "0" : "") + n;
        return pad(d.getHours()) + ":" + pad(d.getMinutes());
    }

    function relativeTime(iso) {
        if (!iso)
            return "";
        const t = Date.parse(iso);
        if (isNaN(t))
            return "";
        const sec = Math.max(0, Math.floor((Date.now() - t) / 1000));
        if (sec < 60)
            return "now";
        const min = Math.floor(sec / 60);
        if (min < 60)
            return min + "m";
        const hr = Math.floor(min / 60);
        if (hr < 24)
            return hr + "h";
        const day = Math.floor(hr / 24);
        if (day < 7)
            return day + "d";
        return Math.floor(day / 7) + "w";
    }

    function requestKind(pr) {
        if (!pr)
            return "";
        if (pr.personal && pr.team)
            return "you + team";
        if (pr.personal)
            return "you";
        if (pr.team)
            return "team";
        return "review";
    }

    function haystack(pr) {
        if (!pr)
            return "";
        const reviewers = (pr.reviewers || []).join(" ");
        return [
            pr.title, pr.author, pr.repo,
            "#" + pr.number, String(pr.number),
            pr.head, pr.base, reviewers,
            pr.personal ? "you me personal" : "",
            pr.team ? "team reviewers" : "",
            pr.isDraft ? "draft" : "",
            requestKind(pr)
        ].join(" ").toLowerCase();
    }

    function matchesQuery(pr, raw) {
        const q = String(raw || "").trim().toLowerCase();
        if (!q)
            return true;
        const terms = q.split(/\s+/);
        for (let i = 0; i < terms.length; i++) {
            const t = terms[i];
            const colon = t.indexOf(":");
            if (colon > 0) {
                const key = t.slice(0, colon);
                const val = t.slice(colon + 1);
                if (!val)
                    continue;
                if (key === "author" || key === "user") {
                    if (!(pr.author || "").toLowerCase().includes(val))
                        return false;
                } else if (key === "repo") {
                    if (!(pr.repo || "").toLowerCase().includes(val))
                        return false;
                } else if (key === "title" || key === "pr") {
                    if (!(pr.title || "").toLowerCase().includes(val))
                        return false;
                } else if (key === "branch" || key === "head") {
                    if (!(pr.head || "").toLowerCase().includes(val))
                        return false;
                } else if (key === "base") {
                    if (!(pr.base || "").toLowerCase().includes(val))
                        return false;
                } else if (key === "kind") {
                    if (!requestKind(pr).toLowerCase().includes(val))
                        return false;
                } else if (!haystack(pr).includes(t)) {
                    return false;
                }
            } else if (!haystack(pr).includes(t)) {
                return false;
            }
        }
        return true;
    }

    function filteredPrs(raw) {
        const list = root.prs || [];
        if (!String(raw || "").trim())
            return list;
        return list.filter(pr => matchesQuery(pr, raw));
    }

    function applyPayload(text) {
        try {
            const data = JSON.parse(text);
            if (!data || data.ok !== true) {
                status = "error";
                errorText = (data && data.error) ? String(data.error).trim().slice(0, 220) : "unexpected response";
                return;
            }
            login = data.login || "";
            count = typeof data.count === "number" ? data.count : ((data.prs || []).length);
            prs = data.prs || [];
            status = "ok";
            errorText = "";
            ready = true;
            lastUpdated = clockTime();
        } catch (e) {
            status = "error";
            errorText = (text || "").trim().slice(0, 220) || e.message;
        }
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: root.applyPayload(text)
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length && root.status === "loading")
                    root.errorText = text.trim().slice(0, 220);
            }
        }
        onExited: (code) => {
            if (code !== 0 && root.status === "loading")
                root.status = "error";
        }
    }

    Timer {
        interval: root.refreshMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}