pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Owns output/input device selection: which sink/source is the system
// default, moving already-running streams onto a newly-selected device (see
// below), and persisting the choice so it doesn't need to be reselected
// every session - AudioPopup just calls selectSink()/selectSource() and
// reads sinks/sources from here instead of duplicating any of this.
//
// PipeWire only makes NEW streams follow a changed default; anything
// already connected (e.g. MPD, which may have linked to a sink earlier in
// the session) stays put until moved explicitly. `pactl move-sink-input`/
// `move-source-output` (the PulseAudio-compatible control surface PipeWire
// ships) is what makes selecting a device here behave like Windows'
// "switch everything to this device" instead of just changing the default
// for future streams - there's no native Pipewire-qml call for reassigning
// an existing stream's link.
QtObject {
    id: root

    // Deliberately not gated on `n.ready` here: a PwNode only flips to
    // ready once something actually tracks it via PwObjectTracker (below),
    // and that tracker is fed by this very list - gating membership on
    // `ready` made any sink/source that wasn't already active elsewhere
    // (i.e. anything other than the current default) impossible to ever
    // discover, since it could never become ready without first being in
    // a list that required it to already be ready. Ungated here, tracked
    // unconditionally below, and it becomes ready shortly after.
    readonly property var sinks: {
        const all = Pipewire.nodes ? Pipewire.nodes.values : [];
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const n = all[i];
            if (n && n.isSink && !n.isStream) out.push(n);
        }
        return out;
    }
    // Sinks commonly expose a "monitor" source port too (to let something
    // capture what's playing on them), which sets the AudioSource type bit
    // right alongside AudioSink - filtering on the type flag alone put
    // actual output devices in this list. Excluding anything that's also a
    // sink (isSink) is what actually narrows this to real microphones/inputs.
    readonly property var sources: {
        const all = Pipewire.nodes ? Pipewire.nodes.values : [];
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const n = all[i];
            if (n && !n.isStream && !n.isSink && (n.type & PwNodeType.AudioSource) !== 0) out.push(n);
        }
        return out;
    }

    // Ensures every discovered sink/source actually gets bound (populating
    // .audio, flipping .ready, etc.) as soon as this service exists -
    // independent of whether AudioPopup happens to be open.
    property PwObjectTracker _tracker: PwObjectTracker {
        objects: root.sinks.concat(root.sources)
    }

    function _findByName(list, name) {
        if (!name) return null;
        for (let i = 0; i < list.length; i++) {
            if (list[i].name === name) return list[i];
        }
        return null;
    }

    property Process _moveOutputsProc: Process {}
    property Process _moveInputsProc: Process {}

    function selectSink(node) {
        if (!node) return;
        Pipewire.preferredDefaultAudioSink = node;
        root._moveOutputsProc.command = ["sh", "-c",
            "pactl list short sink-inputs | cut -f1 | while read -r id; do pactl move-sink-input \"$id\" \"" + node.name + "\"; done"];
        root._moveOutputsProc.running = true;
        root._prefFile.adapter.sinkName = node.name;
        root._prefFile.writeAdapter();
    }

    function selectSource(node) {
        if (!node) return;
        Pipewire.preferredDefaultAudioSource = node;
        root._moveInputsProc.command = ["sh", "-c",
            "pactl list short source-outputs | cut -f1 | while read -r id; do pactl move-source-output \"$id\" \"" + node.name + "\"; done"];
        root._moveInputsProc.running = true;
        root._prefFile.adapter.sourceName = node.name;
        root._prefFile.writeAdapter();
    }

    // ---- Persisted last-selected device, restored on startup ----

    property FileView _prefFile: FileView {
        path: Quickshell.statePath("audio-preference.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) writeAdapter();
        }
        onLoaded: root._tryApplySaved()

        adapter: JsonAdapter {
            property string sinkName: ""
            property string sourceName: ""
        }
    }

    // Re-checked whenever the device list changes shape (a device plugged
    // back in, PipeWire not ready yet at the moment the file first loaded,
    // etc.), so the saved choice gets applied as soon as it's actually
    // available - not just once at startup.
    onSinksChanged: root._tryApplySaved()
    onSourcesChanged: root._tryApplySaved()

    function _tryApplySaved() {
        const sinkName = root._prefFile.adapter.sinkName;
        const savedSink = root._findByName(root.sinks, sinkName);
        if (savedSink && Pipewire.defaultAudioSink !== savedSink) root.selectSink(savedSink);

        const sourceName = root._prefFile.adapter.sourceName;
        const savedSource = root._findByName(root.sources, sourceName);
        if (savedSource && Pipewire.defaultAudioSource !== savedSource) root.selectSource(savedSource);
    }
}
