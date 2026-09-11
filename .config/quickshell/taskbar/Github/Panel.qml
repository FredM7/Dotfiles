import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    property Item anchorItem
    property color fg: "#e6e6e6"
    property color muted: "#9aa0a6"
    property color accent: "#f78166"
    property color bg: "#1c1c1c"
    property color borderColor: "#333"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13
    property string query: ""
    property bool buttonOwnsClick: false

    signal requestClose()

    readonly property var items: {
        const _ = Service.prs;
        return Service.filteredPrs(root.query);
    }
    readonly property string status: Service.status
    readonly property int count: Service.count
    readonly property int shown: items ? items.length : 0
    readonly property bool filtering: query.trim().length > 0

    implicitWidth: 460
    implicitHeight: Math.min(620, Math.max(280, 96 + Math.max(48, shown * 72) + 40))
    color: "transparent"

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        margins.top: 6
    }

    onVisibleChanged: {
        if (visible) {
            armTimer.restart();
        } else {
            armTimer.stop();
            grab.active = false;
            search.clear();
        }
    }

    Timer {
        id: armTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!root.visible)
                return;
            grab.active = true;
            search.focusInput();
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        onCleared: {
            if (root.buttonOwnsClick || armTimer.running || !root.visible)
                return;
            root.requestClose();
        }
        onActiveChanged: {
            if (active)
                search.focusInput();
        }
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
                    text: "Reviews"
                    color: root.fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                }

                Text {
                    text: root.filtering ? (root.shown + "/" + root.count) : (root.count > 0 ? ("" + root.count) : "")
                    color: root.count > 0 ? root.accent : root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    font.bold: true
                    visible: root.count > 0
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Service.login !== "" ? ("@" + Service.login) : ""
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 2
                    visible: Service.login !== ""
                }

                Text {
                    text: root.status === "loading" ? "fetching" : (Service.lastUpdated || "")
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 2
                }

                Text {
                    text: "↻"
                    color: root.muted
                    font.pixelSize: root.fontSize
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Service.refresh()
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

            Search {
                id: search
                width: parent.width
                fg: root.fg
                muted: root.muted
                accent: root.accent
                bg: root.bg
                borderColor: root.borderColor
                fontFamily: root.fontFamily
                fontSize: root.fontSize
                onTextChanged: root.query = text
                onRequestClose: root.requestClose()
            }

            Text {
                visible: root.status === "error" && Service.errorText.length
                width: parent.width
                text: Service.errorText
                color: root.accent
                wrapMode: Text.Wrap
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 2
            }

            Text {
                visible: root.status !== "error" && root.shown === 0
                width: parent.width
                text: root.status === "loading"
                      ? "Fetching review queue…"
                      : (root.filtering ? "No reviews match that filter" : "No pull requests waiting for you")
                color: root.muted
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
            }

            Flickable {
                width: parent.width
                height: Math.max(80, parent.height - header.height - search.height - footer.height - parent.spacing * 3)
                clip: true
                contentWidth: width
                contentHeight: body.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                visible: root.shown > 0

                Column {
                    id: body
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: root.items

                        delegate: Rectangle {
                            property var pr: modelData
                            width: body.width
                            implicitHeight: col.implicitHeight + 14
                            radius: 4
                            color: rowArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"

                            Column {
                                id: col
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 2

                                RowLayout {
                                    width: parent.width
                                    spacing: 6

                                    Text {
                                        Layout.fillWidth: true
                                        text: pr && pr.repo ? pr.repo : ""
                                        color: root.muted
                                        wrapMode: Text.WrapAnywhere
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 2
                                    }

                                    Text {
                                        visible: pr && pr.isDraft
                                        text: "draft"
                                        color: root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 3
                                        font.bold: true
                                    }

                                    Text {
                                        text: Service.requestKind(pr)
                                        color: (pr && pr.personal) ? root.accent : root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 3
                                        font.bold: true
                                    }

                                    Text {
                                        text: Service.relativeTime(pr ? pr.updatedAt : "")
                                        color: root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 3
                                    }
                                }

                                Text {
                                    width: parent.width
                                    visible: pr && (pr.head || pr.base)
                                    text: (pr && pr.head ? pr.head : "?") + " → " + (pr && pr.base ? pr.base : "?")
                                    color: root.muted
                                    wrapMode: Text.WrapAnywhere
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 6

                                    Text {
                                        text: pr && pr.number ? ("#" + pr.number) : ""
                                        color: root.accent
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 1
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: pr && pr.title ? pr.title : ""
                                        color: root.fg
                                        wrapMode: Text.WordWrap
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize
                                    }

                                    Text {
                                        text: pr && pr.author ? pr.author : ""
                                        color: root.muted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 2
                                    }
                                }
                            }

                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (pr && pr.url)
                                        Service.openUrl(pr.url);
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                id: footer
                width: parent.width
                spacing: 8

                Text {
                    text: "you or " + Service.teamSlug
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 2
                    wrapMode: Text.WrapAnywhere
                    Layout.fillWidth: true
                }

                Text {
                    text: "open on GitHub"
                    color: root.accent
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Service.openInbox()
                    }
                }
            }
        }
    }
}