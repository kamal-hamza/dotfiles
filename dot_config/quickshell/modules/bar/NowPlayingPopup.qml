import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../../theme"

// Dropdown for the now-playing pill: album art, track info, round
// prev/play-pause/next buttons and a progress bar - all driven by mpc
// (MPD only, matching the pill). A real xdg-popup anchored to the
// pill's bottom edge, same pattern as CalendarPopup.
PopupWindow {
    id: popup

    required property var anchorWindow
    required property var anchorItem

    signal dismissed()

    visible: false
    color: "transparent"
    grabFocus: true

    anchor {
        window: anchorWindow
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 10
    }

    readonly property int cardWidth: 300
    readonly property int contentWidth: cardWidth - 64
    readonly property string coverPath: "/tmp/quickshell-mpd-cover.jpg"

    implicitWidth: cardWidth
    implicitHeight: card.implicitHeight

    onClosed: popup.dismissed()

    property string title: "Nothing playing"
    property string artist: ""
    property string album: ""
    property string currentFile: ""
    property bool playing: false
    property real progress: 0
    property string elapsed: "0:00"
    property string total: "0:00"
    property int coverVersion: 0

    onCurrentFileChanged: {
        if (currentFile.length > 0)
            coverProcess.running = true;
        else
            coverVersion++;
    }

    function applyCurrent(output) {
        const parts = output.split("\t");
        const trackTitle = parts[0] ? parts[0].trim() : "";
        popup.title = trackTitle.length > 0 ? trackTitle : "Nothing playing";
        popup.artist = parts[1] ? parts[1].trim() : "";
        popup.album = parts[2] ? parts[2].trim() : "";
        popup.currentFile = parts[3] ? parts[3].trim() : "";
    }

    function applyStatus(output) {
        const lines = output.split("\n");
        popup.playing = lines.length > 1 && lines[1].includes("[playing]");

        const match = lines.length > 1 ? lines[1].match(/(\d+:\d+)\/(\d+:\d+)\s*\((\d+)%\)/) : null;
        if (match) {
            popup.elapsed = match[1];
            popup.total = match[2];
            popup.progress = Number(match[3]) / 100;
        } else {
            popup.elapsed = "0:00";
            popup.total = "0:00";
            popup.progress = 0;
        }

        if (lines[0].trim() === "") {
            popup.title = "Nothing playing";
            popup.artist = "";
            popup.album = "";
            popup.currentFile = "";
        }
    }

    Timer {
        interval: 1000
        running: popup.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            currentProcess.running = true;
            statusProcess.running = true;
        }
    }

    Process {
        id: currentProcess
        command: ["mpc", "-f", "%title%\t%artist%\t%album%\t%file%", "current"]
        stdout: StdioCollector {
            onStreamFinished: popup.applyCurrent(text)
        }
    }

    Process {
        id: statusProcess
        command: ["mpc", "status"]
        stdout: StdioCollector {
            onStreamFinished: popup.applyStatus(text)
        }
    }

    Process {
        id: coverProcess
        environment: ({ "MPC_FILE": popup.currentFile, "OUT": popup.coverPath })
        command: ["sh", "-c", "mpc readpicture \"$MPC_FILE\" > \"$OUT\" 2>/dev/null || mpc albumart \"$MPC_FILE\" > \"$OUT\" 2>/dev/null || { rm -f \"$OUT\"; exit 1; }"]
        onExited: popup.coverVersion++
    }

    Process {
        id: toggleProcess
        command: ["mpc", "toggle"]
    }
    Process {
        id: nextProcess
        command: ["mpc", "next"]
    }
    Process {
        id: prevProcess
        command: ["mpc", "prev"]
    }

    Rectangle {
        id: card

        width: popup.cardWidth
        implicitHeight: outerColumn.implicitHeight + 64
        radius: Theme.cardRadius
        color: Theme.background
        border.width: 1
        border.color: Theme.outline

        Column {
            id: outerColumn
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 32
            width: popup.contentWidth
            spacing: 22

            ClippingRectangle {
                id: art
                anchors.horizontalCenter: parent.horizontalCenter
                width: 128
                height: 128
                radius: width / 2
                color: Theme.surface

                Image {
                    id: artImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                    source: popup.currentFile.length > 0
                        ? "file://" + popup.coverPath + "?" + popup.coverVersion
                        : ""
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: popup.title
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    visible: popup.artist.length > 0
                    text: popup.artist
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.text
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    visible: popup.album.length > 0
                    text: popup.album
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.outline
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                // Previous
                Rectangle {
                    width: 34
                    height: 34
                    radius: width / 2
                    color: prevArea.containsMouse ? Theme.surface : "transparent"
                    border.width: 1
                    border.color: Theme.outline

                    Canvas {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Theme.text;
                            ctx.fillRect(width * 0.22, height * 0.2, width * 0.12, height * 0.6);
                            ctx.beginPath();
                            ctx.moveTo(width * 0.8, height * 0.2);
                            ctx.lineTo(width * 0.8, height * 0.8);
                            ctx.lineTo(width * 0.34, height * 0.5);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: prevProcess.running = true
                    }
                }

                // Play / pause
                Rectangle {
                    width: 46
                    height: 46
                    radius: width / 2
                    color: Theme.accent

                    Canvas {
                        id: playPauseIcon
                        anchors.centerIn: parent
                        width: 20
                        height: 20

                        Connections {
                            target: popup
                            function onPlayingChanged() { playPauseIcon.requestPaint(); }
                        }

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Theme.textOnAccent;
                            if (popup.playing) {
                                ctx.fillRect(width * 0.26, height * 0.2, width * 0.18, height * 0.6);
                                ctx.fillRect(width * 0.56, height * 0.2, width * 0.18, height * 0.6);
                            } else {
                                ctx.beginPath();
                                ctx.moveTo(width * 0.28, height * 0.18);
                                ctx.lineTo(width * 0.28, height * 0.82);
                                ctx.lineTo(width * 0.78, height * 0.5);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toggleProcess.running = true
                    }
                }

                // Next
                Rectangle {
                    width: 34
                    height: 34
                    radius: width / 2
                    color: nextArea.containsMouse ? Theme.surface : "transparent"
                    border.width: 1
                    border.color: Theme.outline

                    Canvas {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Theme.text;
                            ctx.beginPath();
                            ctx.moveTo(width * 0.2, height * 0.2);
                            ctx.lineTo(width * 0.2, height * 0.8);
                            ctx.lineTo(width * 0.66, height * 0.5);
                            ctx.closePath();
                            ctx.fill();
                            ctx.fillRect(width * 0.66, height * 0.2, width * 0.12, height * 0.6);
                        }
                    }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nextProcess.running = true
                    }
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 4
                    radius: height / 2
                    color: Theme.outline

                    Rectangle {
                        width: parent.width * popup.progress
                        height: parent.height
                        radius: height / 2
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: Theme.animationMs }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 14

                    Text {
                        anchors.left: parent.left
                        text: popup.elapsed
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.outline
                    }

                    Text {
                        anchors.right: parent.right
                        text: popup.total
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.outline
                    }
                }
            }
        }
    }
}
