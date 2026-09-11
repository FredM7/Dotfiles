import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: root

    property Item anchorItem
    property var service
    property color fg: "#e6e6e6"
    property color muted: "#9aa0a6"
    property color accent: "#f78166"
    property color bg: "#1c1c1c"
    property color borderColor: "#333"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13

    signal requestClose()

    readonly property var items: service && service.notifications ? service.notifications : []
    readonly property string filter: service ? service.inboxFilter : "unread"
    readonly property string status: service ? service.status : "idle"
    readonly property int unread: service ? service.unread : 0

    function stateLabel(n) {
        if (n && n.issueState)
            return n.issueState;
        const t = n && n.subject ? n.subject.type : "";
        if (t === "PullRequest")
            return "pr";
        if (t === "Issue")
            return "issue";
        if (t === "Commit")
            return "commit";
        if (t === "Release")
            return "release";
        if (t === "Discussion")
            return "discuss";
        if (t === "CheckSuite")
            return "check";
        return "";
    }

    function stateColor(label) {
        if (label === "open")
            return "#3fb950";
        if (label === "merged")
            return "#a371f7";
        if (label === "closed")
            return "#f85149";
        return root.muted;
    }

    implicitWidth: 460
    implicitHeight: Math.min(560, Math.max(280, 56 + Math.max(40, items.length * 44) + 52))
    color: "transparent"

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        margins.top: 6
    }

    Rectangle {
        anchors.fill: parent
        color: root.bg
        border.color: root.borderColor
        border.width: 1
        radius: 8

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                id: header
                width: parent.width
                spacing: 8

                Text {
                    text: "Inbox"
                    color: root.fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                TabChip {
                    label: "Unread"
                    count: root.unread
                    active: root.filter === "unread"
                    onClicked: root.service.setFilter("unread")
                }
                TabChip {
                    label: "All"
                    countText: root.service ? root.service.allCountLabel : ""
                    active: root.filter === "all"
                    onClicked: root.service.setFilter("all")
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "fetching"
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    visible: root.status === "loading"
                }
                Text {
                    text: "↻"
                    color: root.muted
                    font.pixelSize: root.fontSize
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.service.refresh()
                    }
                }
                Text {
                    text: "✕"
                    color: root.muted
                    font.pixelSize: root.fontSize
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.requestClose()
                    }
                }
            }

            Text {
                visible: root.status === "error" && root.service && root.service.errorText.length
                width: parent.width
                text: root.service ? root.service.errorText : ""
                color: root.accent
                wrapMode: Text.Wrap
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 2
            }

            Text {
                visible: root.status !== "error" && root.items.length === 0
                width: parent.width
                text: root.status === "loading"
                      ? "Fetching notifications…"
                      : (root.filter === "all" ? "No notifications" : "No unread notifications")
                color: root.muted
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
            }

            Flickable {
                width: parent.width
                height: Math.max(80, parent.height - header.height - pager.height - parent.spacing * 2)
                clip: true
                contentWidth: width
                contentHeight: body.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                visible: root.items.length > 0

                Column {
                    id: body
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: root.items

                        delegate: Rectangle {
                            property var n: modelData
                            width: body.width
                            implicitHeight: col.implicitHeight + 12
                            radius: 4
                            color: rowArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
                            opacity: n && n.unread === false ? 0.55 : 1

                            Text {
                                id: stateChip
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                width: 52
                                text: root.stateLabel(n)
                                color: root.stateColor(root.stateLabel(n))
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }

                            Column {
                                id: col
                                anchors.left: stateChip.right
                                anchors.right: markBtn.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: ((n && n.repository) ? n.repository.full_name : "")
                                          + " · " + root.service.reasonLabel(n ? n.reason : "")
                                    color: root.muted
                                    elide: Text.ElideRight
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                }
                                Text {
                                    width: parent.width
                                    text: (n && n.subject) ? n.subject.title : ""
                                    color: root.fg
                                    elide: Text.ElideRight
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize
                                }
                            }

                            Text {
                                id: markBtn
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: n && n.unread === false ? "·" : "✓"
                                color: root.muted
                                font.pixelSize: root.fontSize
                                visible: !(n && n.unread === false)

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        mouse.accepted = true;
                                        if (n)
                                            root.service.markRead(n.id);
                                    }
                                }
                            }

                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                anchors.rightMargin: 28
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!n)
                                        return;
                                    // Open only. Does not mark read or done.
                                    root.service.openUrl(root.service.htmlUrl(n));
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                id: pager
                width: parent.width
                spacing: 6

                Text {
                    text: "Page " + (root.service ? root.service.listPage : 1)
                          + " / " + (root.service ? root.service.pageCount : 1)
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "‹"
                    color: root.service && root.service.listPage > 1 ? root.fg : root.muted
                    font.pixelSize: root.fontSize + 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        enabled: root.service && root.service.listPage > 1
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.service.setPage(root.service.listPage - 1)
                    }
                }

                Repeater {
                    model: root.service ? root.service.pageCount : 1
                    delegate: Rectangle {
                        required property int index
                        readonly property int page: index + 1
                        implicitWidth: 22
                        implicitHeight: 20
                        radius: 4
                        color: root.service && root.service.listPage === page ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                        border.width: root.service && root.service.listPage === page ? 0 : 1
                        border.color: root.borderColor

                        Text {
                            anchors.centerIn: parent
                            text: "" + page
                            color: root.service && root.service.listPage === page ? root.fg : root.muted
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.service.setPage(page)
                        }
                    }
                }

                Text {
                    text: "›"
                    color: root.service && root.service.listPage < root.service.pageCount ? root.fg : root.muted
                    font.pixelSize: root.fontSize + 2
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        enabled: root.service && root.service.listPage < root.service.pageCount
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.service.setPage(root.service.listPage + 1)
                    }
                }
            }
        }
    }

    component TabChip: Rectangle {
        property string label
        property int count: -1
        property string countText: ""
        property bool active: false
        signal clicked()

        implicitWidth: tabText.implicitWidth + 14
        implicitHeight: 20
        radius: 4
        color: active ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
        border.width: active ? 0 : 1
        border.color: root.borderColor

        Text {
            id: tabText
            anchors.centerIn: parent
            text: countText.length ? (label + " " + countText)
                  : (count >= 0 ? label + " " + count : label)
            color: active ? root.fg : root.muted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 1
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}