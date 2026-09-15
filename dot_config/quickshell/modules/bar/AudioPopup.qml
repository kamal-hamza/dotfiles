import QtQuick
import Quickshell
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
// doesn't need to be reselected every session. Per-app mixer below that.
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
            if (n && n.isStream && !n.isSink) out.push(n);
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

    Column {
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
    Column {
        width: parent.width
        spacing: Theme.spacing.sm
        visible: popup._streams.length > 0

        Text {
            text: "Applications"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Repeater {
            model: ScriptModel { values: popup._streams }

            delegate: Column {
                id: streamRow
                required property var modelData

                width: parent ? parent.width : 260
                spacing: 4

                Row {
                    width: parent.width

                    Text {
                        width: parent.width - streamMuteIcon.width - Theme.spacing.xs
                        text: streamRow.modelData.description || streamRow.modelData.nickname || streamRow.modelData.name
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        elide: Text.ElideRight
                    }

                    Text {
                        id: streamMuteIcon
                        text: streamRow.modelData.audio && streamRow.modelData.audio.muted ? "󰖁" : "󰕾"
                        color: Theme.textTertiary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (streamRow.modelData.audio)
                                    streamRow.modelData.audio.muted = !streamRow.modelData.audio.muted;
                            }
                        }
                    }
                }

                Slider {
                    width: parent.width
                    value: streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0
                    onMoved: v => {
                        if (streamRow.modelData.audio) streamRow.modelData.audio.volume = v;
                    }
                }
            }
        }
    }
}
