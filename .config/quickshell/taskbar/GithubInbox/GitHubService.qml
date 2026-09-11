pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property var notifications: []
    property int unread: 0
    property int allCount: 0
    property bool allCapped: false
    readonly property string allCountLabel: allCount > 0 ? (allCapped ? (allCount + "+") : ("" + allCount)) : ""
    property string status: "idle"   // idle | loading | error | ok
    property string errorText: ""
    property bool ready: false
    property int refreshMs: 5 * 60 * 1000
    // "unread" → GET /notifications
    // "all"    → GET /notifications?all=true
    property string inboxFilter: "unread"
    property int listPage: 1
    readonly property int pageSize: 50
    readonly property int pageCount: {
        const total = root.inboxFilter === "all" ? root.allCount : root.unread;
        if (total <= 0)
            return 1;
        return Math.max(1, Math.ceil(total / root.pageSize));
    }

    function endpoint() {
        const page = Math.max(1, root.listPage);
        return root.inboxFilter === "all"
            ? "/notifications?all=true&per_page=" + root.pageSize + "&page=" + page
            : "/notifications?per_page=" + root.pageSize + "&page=" + page;
    }

    function refresh() {
        if (fetchProc.running)
            return;
        status = "loading";
        errorText = "";
        fetchProc.command = [
            "sh", "-c",
            "GH_PAGER=cat gh api -H 'Accept: application/vnd.github+json' '" + root.endpoint() + "'"
        ];
        fetchProc.running = true;
    }

    function setFilter(next) {
        if (next !== "all" && next !== "unread")
            return;
        if (root.inboxFilter === next && root.ready)
            return;
        root.inboxFilter = next;
        root.listPage = 1;
        root.refresh();
    }

    function setPage(next) {
        const page = Math.max(1, Math.min(root.pageCount, Number(next) || 1));
        if (page === root.listPage && root.ready)
            return;
        root.listPage = page;
        root.refresh();
    }

    function openUrl(url) {
        if (!url)
            return;
        Quickshell.execDetached(["xdg-open", url]);
    }

    function htmlUrl(n) {
        const api = n && n.subject && n.subject.url ? n.subject.url : "";
        if (!api)
            return n && n.repository ? n.repository.html_url : "https://github.com/notifications";
        return api
            .replace("https://api.github.com/repos/", "https://github.com/")
            .replace("/pulls/", "/pull/")
            .replace("/commits/", "/commit/");
    }

    function reasonLabel(reason) {
        const map = {
            assign: "assigned",
            author: "author",
            comment: "comment",
            invitation: "invite",
            manual: "subscribed",
            mention: "mentioned",
            review_requested: "review",
            security_alert: "security",
            state_change: "state",
            subscribed: "watching",
            team_mention: "team",
            ci_activity: "actions"
        };
        return map[reason] || reason || "";
    }

    // PATCH = mark read. Never DELETE (that is "Done" and removes the thread
    // from GitHub's inbox). This panel must not mark anything Done.
    function markRead(id) {
        if (!id || markProc.running)
            return;
        markProc.command = ["sh", "-c", "GH_PAGER=cat gh api --method PATCH '/notifications/threads/" + id + "'"];
        markProc.running = true;
        notifications = notifications.map(n => {
            if (n.id !== id)
                return n;
            const copy = Object.assign({}, n);
            copy.unread = false;
            return copy;
        });
        unread = Math.max(0, unread - 1);
        if (root.inboxFilter === "unread")
            notifications = notifications.filter(n => n.id !== id);
    }

    function markAllRead() {
        if (markProc.running)
            return;
        markProc.command = ["sh", "-c", "GH_PAGER=cat gh api --method PUT /notifications"];
        markProc.running = true;
        if (root.inboxFilter === "unread")
            notifications = [];
        else
            notifications = notifications.map(n => Object.assign({}, n, { unread: false }));
        unread = 0;
    }

    function parsePayload(text) {
        try {
            const data = JSON.parse(text);
            if (!Array.isArray(data)) {
                status = "error";
                errorText = (data && data.message) ? data.message : "unexpected response";
                return;
            }
            notifications = data;
            if (root.inboxFilter === "unread")
                unread = data.filter(n => n.unread !== false).length;
            root.refreshAllCount();
            status = "ok";
            errorText = "";
            ready = true;
            root.enrichStates(data);
        } catch (e) {
            status = "error";
            errorText = (text || "").trim().slice(0, 200) || e.message;
        }
    }

    function enrichStates(rows) {
        if (!rows || !rows.length || enrichProc.running)
            return;
        const aliases = [];
        for (let i = 0; i < rows.length; i++) {
            const url = rows[i] && rows[i].subject ? (rows[i].subject.url || "") : "";
            const m = url.match(/\/repos\/([^/]+)\/([^/]+)\/(pulls|issues)\/(\d+)/);
            if (!m)
                continue;
            const owner = m[1];
            const repo = m[2];
            const kind = m[3];
            const num = m[4];
            if (kind === "pulls")
                aliases.push("n" + i + ": repository(owner: \"" + owner + "\", name: \"" + repo + "\") { pullRequest(number: " + num + ") { state merged } }");
            else
                aliases.push("n" + i + ": repository(owner: \"" + owner + "\", name: \"" + repo + "\") { issue(number: " + num + ") { state } }");
        }
        if (!aliases.length)
            return;
        const query = "query { " + aliases.join(" ") + " }";
        enrichProc.command = ["sh", "-c", "GH_PAGER=cat gh api graphql -f query=" + JSON.stringify(query)];
        enrichProc.running = true;
    }

    function refreshAllCount() {
        if (allCountProc.running)
            return;
        allCountProc.command = ["sh", "-c", [
            "GH_PAGER=cat",
            "count=0",
            "capped=false",
            "for page in 1 2 3 4; do",
            "  n=$(gh api -H 'Accept: application/vnd.github+json' \"/notifications?all=true&per_page=50&page=$page\" | jq 'if type==\"array\" then length else 0 end')",
            "  n=${n:-0}",
            "  count=$((count + n))",
            "  if [ \"$n\" -lt 50 ]; then capped=false; break; fi",
            "  if [ \"$page\" -eq 4 ]; then capped=true; fi",
            "done",
            "printf '{\"count\":%s,\"capped\":%s}\\n' \"$count\" \"$capped\""
        ].join("\n")];
        allCountProc.running = true;
    }

    function parseAllCount(text) {
        try {
            const data = JSON.parse(text);
            if (data && typeof data.count === "number") {
                allCount = data.count;
                allCapped = !!data.capped;
            }
        } catch (e) {
        }
    }

    function applyStates(text) {
        try {
            const parsed = JSON.parse(text);
            const payload = parsed.data || parsed;
            if (!payload || typeof payload !== "object")
                return;
            notifications = notifications.map((n, i) => {
                const node = payload["n" + i];
                if (!node)
                    return n;
                const copy = Object.assign({}, n);
                if (node.pullRequest) {
                    const st = String(node.pullRequest.state || "").toUpperCase();
                    copy.issueState = (node.pullRequest.merged || st === "MERGED") ? "merged" : st.toLowerCase();
                } else if (node.issue) {
                    copy.issueState = String(node.issue.state || "").toLowerCase();
                }
                return copy;
            });
        } catch (e) {
        }
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: root.parsePayload(text)
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length)
                    root.errorText = text.trim().slice(0, 200);
            }
        }
        onExited: (code) => {
            if (code !== 0 && root.status === "loading")
                root.status = "error";
        }
    }

    Process {
        id: allCountProc
        stdout: StdioCollector {
            onStreamFinished: root.parseAllCount(text)
        }
    }

    Process {
        id: enrichProc
        stdout: StdioCollector {
            onStreamFinished: root.applyStates(text)
        }
    }

    Process {
        id: markProc
        onExited: (code) => {
            if (code !== 0)
                root.refresh();
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