import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../theme"
import "../common"
import "../services"

// Body shown from the volume pill: every output/input device gets its own
// row with a name, mute toggle, and volume slider - PipeWire node volume is
// a property of the node itself, not just the system default, so any
// device's level can be adjusted directly without switching to it first.
// Clicking the device name switches to it; AudioService remembers the
// choice and moves already-running streams onto it (see
// modules/services/AudioService.qml for why that's necessary), so it
// doesn't need to be reselected every session. The per-app mixer lives on
// its own "Mixer" tab, with MPD pinned at the top (see "MPD via mpc").
PopupCard {
    id: popup

    cardWidth: 300

    // Not gated on `n.ready` for the same reason AudioService's sinks/
    // sources aren't: a stream only becomes ready once tracked, so
    // requiring readiness just to notice it in the first place would mean
    // a freshly-opened app's stream could never appear.
    readonly property var _streams: {
        const all = Pipewire.nodes ? Pipewire.nodes.values : [];
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const n = all[i];
            // Playback streams carry the Sink bit too (AudioOutStream =
            // Audio|Stream|Sink), so `isSink` can't be used to tell them
            // apart from recording streams - match the full type instead.
            if (!n || !n.isStream) continue;
            if ((n.type & PwNodeType.AudioOutStream) !== PwNodeType.AudioOutStream) continue;
            // MPD has its own pinned mpc-driven row (see "MPD via mpc").
            if (n.name && n.name.startsWith("mpd.")) continue;
            out.push(n);
        }
        return out;
    }

    // AudioService already tracks every sink/source unconditionally; this
    // only needs to additionally track the per-app streams shown below.
    PwObjectTracker {
        objects: popup._streams
    }

    // The name row is the click target for "make this the active device" -
    // a plain MouseArea sized to just that row (not the whole item), so it
    // can never end up fighting the slider's drag area or the mute icon's
    // own click area below/beside it for hit-testing priority.
    component DeviceRow: Column {
        id: row
        required property var node
        required property bool isDefault
        signal activate()

        width: parent ? parent.width : 260
        spacing: 3

        Item {
            id: nameRow
            width: parent.width
            height: 20

            // Background+click target for "make this the active device",
            // sized to everything left of the mute icon. A plain Item (not
            // a Row) so this anchors-based overlay doesn't fight Row's own
            // automatic left-to-right placement of its siblings.
            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: muteIcon.width + Theme.spacing.xs
                z: -1
                radius: Theme.radius.control
                color: nameMa.containsMouse ? Theme.bgHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                MouseArea {
                    id: nameMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.activate()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: checkGlyph.left
                text: row.node ? (row.node.nickname || row.node.description || row.node.name) : ""
                color: row.isDefault ? Theme.textStrong : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: row.isDefault
                elide: Text.ElideRight
            }
            Text {
                id: checkGlyph
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: muteIcon.left
                anchors.rightMargin: Theme.spacing.xs
                text: row.isDefault ? "󰄬" : "" // nf-md-check, only when active
                color: Theme.emphasis
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }
            Text {
                id: muteIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                text: row.node && row.node.audio && row.node.audio.muted ? "󰖁" : "󰕾"
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (row.node && row.node.audio) row.node.audio.muted = !row.node.audio.muted;
                    }
                }
            }
        }

        Slider {
            width: parent.width
            value: row.node && row.node.audio ? row.node.audio.volume : 0
            onMoved: v => {
                if (row.node && row.node.audio) row.node.audio.volume = v;
            }
        }
    }

    // "Devices" (output/input) and "Mixer" (per-app) are separate tabs
    // rather than one long scroll. Remembers the last tab across opens.
    property int tab: 0

    component TabButton: Rectangle {
        id: tabBtn
        required property string label
        required property int index
        readonly property bool selected: popup.tab === tabBtn.index

        width: (parent.width - Theme.spacing.xs) / 2
        height: 24
        radius: Theme.radius.control
        color: tabBtn.selected ? Theme.bgHover : (tabMa.containsMouse ? Theme.bgHover : "transparent")
        border.width: tabBtn.selected ? 1 : 0
        border.color: Theme.border

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Text {
            anchors.centerIn: parent
            text: tabBtn.label
            color: tabBtn.selected ? Theme.textStrong : Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            font.bold: tabBtn.selected
        }

        MouseArea {
            id: tabMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popup.tab = tabBtn.index
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.xs

        TabButton { label: "Devices"; index: 0 }
        TabButton { label: "Mixer"; index: 1 }
    }

    Column {
        visible: popup.tab === 0
        width: parent.width
        spacing: 2

        Text {
            text: "Output"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            bottomPadding: 2
        }

        Repeater {
            model: ScriptModel { values: AudioService.sinks }

            delegate: DeviceRow {
                required property var modelData
                node: modelData
                isDefault: Pipewire.defaultAudioSink !== null && modelData.id === Pipewire.defaultAudioSink.id
                onActivate: AudioService.selectSink(modelData)
            }
        }

        Text {
            visible: AudioService.sinks.length === 0
            text: "No output devices"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
    }

    Column {
        visible: popup.tab === 0
        width: parent.width
        spacing: 2

        Text {
            text: "Input"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            bottomPadding: 2
        }

        Repeater {
            model: ScriptModel { values: AudioService.sources }

            delegate: DeviceRow {
                required property var modelData
                node: modelData
                isDefault: Pipewire.defaultAudioSource !== null && modelData.id === Pipewire.defaultAudioSource.id
                onActivate: AudioService.selectSource(modelData)
            }
        }

        Text {
            visible: AudioService.sources.length === 0
            text: "No input devices"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
    }


    // ---- Per-app mixer ----
    //
    // One row per app: a bold app name, what it's playing underneath (when
    // the stream says), mute toggle, and volume slider. MPD gets a pinned
    // row of its own driven through `mpc` rather than its PipeWire stream:
    // MPD only holds that stream open while it's actually outputting, so a
    // stream-based row would vanish whenever playback stops - `mpc volume`
    // works regardless and is the same knob (MPD's pipewire output maps its
    // mixer onto the stream's volume), so the stream itself is filtered out
    // of the generic list below to avoid a duplicate row.
    component MixerRow: Column {
        id: mixRow
        property string title: ""
        property string subtitle: ""
        property bool muted: false
        property real value: 0
        signal toggleMute()
        signal moved(real v)

        width: parent ? parent.width : 260
        spacing: 4

        Item {
            width: parent.width
            height: mixLabels.implicitHeight

            Column {
                id: mixLabels
                anchors.left: parent.left
                anchors.right: mixMute.left
                anchors.rightMargin: Theme.spacing.xs

                Text {
                    width: parent.width
                    text: mixRow.title
                    color: mixRow.muted ? Theme.textTertiary : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    font.bold: true
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    visible: mixRow.subtitle !== "" && mixRow.subtitle !== mixRow.title
                    text: mixRow.subtitle
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    elide: Text.ElideRight
                }
            }

            Text {
                id: mixMute
                anchors.top: parent.top
                anchors.right: parent.right
                text: (mixRow.muted ? "󰖁 " : "󰕾 ") + Math.round(mixRow.value * 100) + "%"
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mixRow.toggleMute()
                }
            }
        }

        Slider {
            width: parent.width
            value: mixRow.value
            fillColor: mixRow.muted ? Theme.textTertiary : Theme.emphasis
            onMoved: v => mixRow.moved(v)
        }
    }

    // ---- MPD via mpc ----
    // Only polled while the popup is open: `mpc idleloop mixer player`
    // prints a line on every volume/track change, each of which triggers a
    // fresh `mpc status`. If MPD isn't running (idleloop exits), the row
    // hides and a timer retries.
    property bool _mpdAvailable: false
    property real _mpdVolume: 0
    property string _mpdSong: ""
    property real _mpdPreMute: 0.5
    property real _mpdPending: -1

    function _refreshMpd() {
        if (!_mpdStatusProc.running) _mpdStatusProc.running = true;
    }

    function _setMpdVolume(v) {
        popup._mpdVolume = v; // optimistic, so dragging feels immediate
        popup._mpdPending = Math.round(v * 100);
        if (!_mpdSetProc.running) popup._flushMpdVolume();
    }

    function _flushMpdVolume() {
        if (popup._mpdPending < 0) return;
        _mpdSetProc.command = ["mpc", "-q", "volume", String(popup._mpdPending)];
        popup._mpdPending = -1;
        _mpdSetProc.running = true;
    }

    onVisibleChanged: {
        if (visible) {
            _refreshMpd();
            _mpdIdleProc.running = true;
        } else {
            _mpdRetry.stop();
            _mpdIdleProc.running = false;
        }
    }

    Process {
        id: _mpdStatusProc
        command: ["mpc", "-f", "[[%artist% - ]%title%]|[%file%]", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const volLine = lines.find(l => l.startsWith("volume:")) || "";
                const m = volLine.match(/^volume:\s*(\d+)%/);
                if (m) popup._mpdVolume = Number(m[1]) / 100;
                // Song + "[playing]" lines only exist when something is queued.
                popup._mpdSong = lines.length >= 3 ? lines[0] : "";
            }
        }
        onExited: code => popup._mpdAvailable = code === 0
    }

    Process {
        id: _mpdSetProc
        onExited: popup._flushMpdVolume()
    }

    Process {
        id: _mpdIdleProc
        command: ["mpc", "idleloop", "mixer", "player"]
        stdout: SplitParser {
            onRead: _ => popup._refreshMpd()
        }
        onExited: {
            popup._mpdAvailable = false;
            if (popup.visible) _mpdRetry.restart();
        }
    }

    Timer {
        id: _mpdRetry
        interval: 3000
        onTriggered: {
            if (!popup.visible) return;
            popup._refreshMpd();
            _mpdIdleProc.running = true;
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.sm
        visible: popup.tab === 1

        Text {
            visible: !popup._mpdAvailable && popup._streams.length === 0
            text: "Nothing is playing audio"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        MixerRow {
            visible: popup._mpdAvailable
            title: "Music (MPD)"
            subtitle: popup._mpdSong
            value: popup._mpdVolume
            muted: popup._mpdVolume <= 0
            onMoved: v => popup._setMpdVolume(v)
            onToggleMute: {
                if (popup._mpdVolume > 0) {
                    popup._mpdPreMute = popup._mpdVolume;
                    popup._setMpdVolume(0);
                } else {
                    popup._setMpdVolume(popup._mpdPreMute > 0 ? popup._mpdPreMute : 0.5);
                }
            }
        }

        Repeater {
            model: ScriptModel { values: popup._streams }

            delegate: MixerRow {
                required property var modelData
                readonly property var props: modelData.properties || ({})

                readonly property string rawName: props["application.name"] || props["application.process.binary"]
                    || modelData.nickname || modelData.description || modelData.name || ""
                // OpenAL-backed Java games (i.e. Minecraft) only identify as
                // "java"; the Game media role is the giveaway.
                title: rawName === "java" && props["media.role"] === "Game" ? "Minecraft" : rawName
                // Generic placeholder media names say nothing useful.
                subtitle: /^(playback( stream)?|audio stream)?$/i.test(props["media.name"] || "")
                    ? "" : props["media.name"]
                value: modelData.audio ? modelData.audio.volume : 0
                muted: modelData.audio ? modelData.audio.muted : false
                onMoved: v => { if (modelData.audio) modelData.audio.volume = v; }
                onToggleMute: { if (modelData.audio) modelData.audio.muted = !modelData.audio.muted; }
            }
        }
    }
}
