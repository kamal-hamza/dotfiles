pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU/RAM sampling (cheap: one Process every 2s, plain /proc parsing) always
// runs so the bar pill can show live numbers - this is the "System Info"
// half of the brief. GPU/disk/network/top-process sampling is comparatively
// more expensive (df, ps, sysfs globbing) and only runs while something
// opts in via startDetail()/stopDetail() - this is the "on-demand" half of
// the Activity Monitor brief. Everything here is /proc, /sys, df, ps, awk -
// deliberately not the compiled-C++-helper approach some reference configs
// use for this, which is disproportionate for what's actually needed here.
QtObject {
    id: root

    property real cpuPercent: 0
    property real ramPercent: 0
    property real ramUsedMb: 0
    property real ramTotalMb: 0

    property real diskUsedGb: 0
    property real diskTotalGb: 0
    property real diskPercent: 0

    property real netRxKBs: 0
    property real netTxKBs: 0

    property bool gpuAvailable: false
    property real gpuPercent: 0
    property real vramUsedMb: 0
    property real vramTotalMb: 0
    property real gpuTempC: 0

    property bool cpuTempAvailable: false
    property real cpuTempC: 0

    property var topProcesses: [] // [{pid, name, cpu, mem}]

    property int _detailUsers: 0
    readonly property bool _detailActive: root._detailUsers > 0
    function startDetail() { root._detailUsers++; }
    function stopDetail() { root._detailUsers = Math.max(0, root._detailUsers - 1); }

    // ---- CPU/RAM: light tier, always sampling ----

    property var _prevCpu: null // {total, idle}

    function _parseLight(text) {
        const lines = text.trim().split("\n");
        if (lines.length < 2) return;

        const cpuFields = lines[0].trim().split(/\s+/).slice(1).map(Number);
        const total = cpuFields.reduce((a, b) => a + b, 0);
        const idle = cpuFields[3] + (cpuFields[4] || 0);

        if (root._prevCpu) {
            const dTotal = total - root._prevCpu.total;
            const dIdle = idle - root._prevCpu.idle;
            if (dTotal > 0) root.cpuPercent = Math.max(0, Math.min(100, 100 * (1 - dIdle / dTotal)));
        }
        root._prevCpu = { total: total, idle: idle };

        const memParts = lines[1].trim().split(/\s+/).map(Number);
        const totalKb = memParts[0] || 0;
        const usedKb = memParts[1] || 0;
        root.ramTotalMb = totalKb / 1024;
        root.ramUsedMb = usedKb / 1024;
        root.ramPercent = totalKb > 0 ? (usedKb / totalKb) * 100 : 0;
    }

    property Process _lightProc: Process {
        command: ["sh", "-c", "head -1 /proc/stat; awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t, t-a}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root._parseLight(text)
        }
    }

    property Timer _lightTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._lightProc.running = true
    }

    // ---- Disk/network/GPU/CPU-temp/top-processes: detail tier, on-demand ----

    property var _prevNet: null // {rx, tx}

    readonly property string _detailScript: [
        "df -B1 / | tail -1 | awk '{print \"DISK\", $2, $3}'",
        "awk 'NR > 2 && $1 !~ /^lo:/ {rx += $2; tx += $10} END{print \"NET\", rx + 0, tx + 0}' /proc/net/dev",
        "for c in /sys/class/drm/card*/device; do " +
            "d=$(basename \"$(readlink -f \"$c/driver\" 2>/dev/null)\"); " +
            "if [ \"$d\" = amdgpu ]; then " +
                "b=$(cat \"$c/gpu_busy_percent\" 2>/dev/null); " +
                "vu=$(cat \"$c/mem_info_vram_used\" 2>/dev/null); " +
                "vt=$(cat \"$c/mem_info_vram_total\" 2>/dev/null); " +
                "t=$(cat \"$c\"/hwmon/hwmon*/temp1_input 2>/dev/null | head -1); " +
                "echo \"GPU ${b:-0} ${vu:-0} ${vt:-0} ${t:-0}\"; break; " +
            "fi; done",
        "for h in /sys/class/hwmon/hwmon*; do " +
            "n=$(cat \"$h/name\" 2>/dev/null); " +
            "if [ \"$n\" = k10temp ]; then " +
                "t=$(cat \"$h/temp1_input\" 2>/dev/null); echo \"CPUTEMP ${t:-0}\"; break; " +
            "fi; done",
        // comm can contain spaces (e.g. Firefox's "Isolated Web Co" content
        // processes) - pid/%cpu/%mem are blanked out of $0 first so the
        // remainder (the name, whatever it contains) can be taken as one
        // field instead of splitting on its internal whitespace.
        "ps -eo pid,%cpu,%mem,comm --sort=-%cpu --no-headers | head -6 | " +
            "awk '{pid=$1; cpu=$2; mem=$3; $1=$2=$3=\"\"; name=$0; " +
            "gsub(/^[ \\t]+/, \"\", name); printf \"PROC\\t%s\\t%s\\t%s\\t%s\\n\", pid, name, cpu, mem}'"
    ].join("\n")

    function _parseDetail(text) {
        const lines = text.split("\n");
        const procs = [];
        let sawGpu = false;
        let sawCpuTemp = false;

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (!line.trim()) continue;

            if (line.indexOf("DISK") === 0) {
                const p = line.trim().split(/\s+/);
                const total = Number(p[1]) || 0;
                const used = Number(p[2]) || 0;
                root.diskTotalGb = total / 1e9;
                root.diskUsedGb = used / 1e9;
                root.diskPercent = total > 0 ? (used / total) * 100 : 0;
            } else if (line.indexOf("NET") === 0) {
                const p = line.trim().split(/\s+/);
                const rx = Number(p[1]) || 0;
                const tx = Number(p[2]) || 0;
                if (root._prevNet) {
                    root.netRxKBs = Math.max(0, (rx - root._prevNet.rx) / 1024 / 2);
                    root.netTxKBs = Math.max(0, (tx - root._prevNet.tx) / 1024 / 2);
                }
                root._prevNet = { rx: rx, tx: tx };
            } else if (line.indexOf("GPU") === 0) {
                sawGpu = true;
                const p = line.trim().split(/\s+/);
                root.gpuPercent = Number(p[1]) || 0;
                root.vramUsedMb = (Number(p[2]) || 0) / 1024 / 1024;
                root.vramTotalMb = (Number(p[3]) || 0) / 1024 / 1024;
                root.gpuTempC = (Number(p[4]) || 0) / 1000;
            } else if (line.indexOf("CPUTEMP") === 0) {
                sawCpuTemp = true;
                const p = line.trim().split(/\s+/);
                root.cpuTempC = (Number(p[1]) || 0) / 1000;
            } else if (line.indexOf("PROC") === 0) {
                const p = line.split("\t");
                if (p.length >= 5)
                    procs.push({ pid: p[1], name: p[2], cpu: Number(p[3]) || 0, mem: Number(p[4]) || 0 });
            }
        }

        root.gpuAvailable = sawGpu;
        root.cpuTempAvailable = sawCpuTemp;
        root.topProcesses = procs;
    }

    property Process _detailProc: Process {
        command: ["sh", "-c", root._detailScript]
        stdout: StdioCollector {
            onStreamFinished: root._parseDetail(text)
        }
    }

    property Timer _detailTimer: Timer {
        interval: 2000
        running: root._detailActive
        repeat: true
        triggeredOnStart: true
        onTriggered: root._detailProc.running = true
    }

    function formatMb(mb) {
        if (mb >= 1024) return (mb / 1024).toFixed(1) + " GB";
        return Math.round(mb) + " MB";
    }
    function formatKBs(kbs) {
        if (kbs >= 1024) return (kbs / 1024).toFixed(1) + " MB/s";
        return Math.round(kbs) + " KB/s";
    }
}
