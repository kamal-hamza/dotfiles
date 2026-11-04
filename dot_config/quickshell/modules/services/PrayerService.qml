pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backs the Prayer pill + PrayerPopup. Location/method choices persist to
// ~/.local/state/quickshell/prayer.json via FileView+JsonAdapter (same
// convention as WeatherService's city list).
//
// Location: by default it is approximated from the public IP (ipinfo.io,
// falling back to ip-api.com - neither needs a key) and re-detected on every
// shell start so it follows you when travelling. Picking a city from the
// search (Open-Meteo geocoding, same as the world clocks) pins it and turns
// auto-detection off until "Use my location" is chosen again.
//
// Times are computed locally (the PrayTimes.org algorithm), not fetched, so
// they keep working offline once a location is known. Everything is held as
// absolute epoch ms; the location's UTC offset (from `TZ=<zone> date +%z`,
// so DST is handled by the system tz database) is only used to pick the
// location's calendar day and to format wall-clock times for display.
QtObject {
    id: root

    // ---- Persisted settings ----

    property FileView _stateFile: FileView {
        path: Quickshell.statePath("prayer.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                writeAdapter();
                root._start();
            }
        }
        onLoaded: root._start()

        adapter: JsonAdapter {
            // {name, country, countryCode, lat, lon, timezone}
            property var location: ({})
            property bool autoLocate: true
            property string method: "auto"
            property bool hanafi: false
        }
    }

    readonly property var location: root._stateFile.adapter.location
    readonly property bool hasLocation: root.location && root.location.lat !== undefined
    readonly property bool autoLocate: root._stateFile.adapter.autoLocate
    readonly property bool hanafi: root._stateFile.adapter.hanafi
    readonly property string methodSetting: root._stateFile.adapter.method

    property bool _started: false
    function _start() {
        if (root._started) {
            root._recompute();
            return;
        }
        root._started = true;
        if (root.autoLocate || !root.hasLocation) root.detectLocation();
        else root._refreshOffset();
    }

    function _setLocation(loc, auto) {
        root._stateFile.adapter.location = loc;
        root._stateFile.adapter.autoLocate = auto;
        root._stateFile.writeAdapter();
        root._refreshOffset();
    }

    function setMethod(key) {
        root._stateFile.adapter.method = key;
        root._stateFile.writeAdapter();
        root._recompute();
    }

    function setHanafi(on) {
        root._stateFile.adapter.hanafi = on;
        root._stateFile.writeAdapter();
        root._recompute();
    }

    // ---- Calculation methods (fajr/isha twilight angles in degrees;
    // ishaMinutes = fixed interval after maghrib instead of an angle) ----

    readonly property var methods: [
        { key: "auto", name: "Auto (by country)" },
        { key: "MWL", name: "Muslim World League", fajr: 18, isha: 17 },
        { key: "ISNA", name: "ISNA (North America)", fajr: 15, isha: 15 },
        { key: "Egypt", name: "Egyptian Authority", fajr: 19.5, isha: 17.5 },
        { key: "Makkah", name: "Umm al-Qura, Makkah", fajr: 18.5, ishaMinutes: 90 },
        { key: "Karachi", name: "Univ. of Karachi", fajr: 18, isha: 18 },
        { key: "Tehran", name: "Inst. of Geophysics, Tehran", fajr: 17.7, isha: 14, maghrib: 4.5 },
        { key: "Turkey", name: "Diyanet, Turkey", fajr: 18, isha: 17 },
        { key: "Singapore", name: "MUIS, Singapore", fajr: 20, isha: 18 }
    ]

    function _methodByKey(key) {
        for (let i = 0; i < root.methods.length; i++)
            if (root.methods[i].key === key) return root.methods[i];
        return null;
    }

    function _autoMethodKey(cc) {
        const table = {
            US: "ISNA", CA: "ISNA", MX: "ISNA",
            SA: "Makkah", YE: "Makkah", BH: "Makkah", KW: "Makkah", QA: "Makkah", AE: "Makkah", OM: "Makkah",
            EG: "Egypt", SY: "Egypt", LB: "Egypt", IQ: "Egypt", JO: "Egypt", PS: "Egypt", LY: "Egypt", SD: "Egypt", MY: "Egypt",
            PK: "Karachi", IN: "Karachi", BD: "Karachi", AF: "Karachi",
            IR: "Tehran",
            TR: "Turkey",
            SG: "Singapore", ID: "Singapore", BN: "Singapore"
        };
        return table[(cc || "").toUpperCase()] || "MWL";
    }

    readonly property var activeMethod: {
        const key = root.methodSetting === "auto"
            ? root._autoMethodKey(root.location ? root.location.countryCode : "")
            : root.methodSetting;
        return root._methodByKey(key) || root._methodByKey("MWL");
    }

    function cycleMethod() {
        let i = 0;
        for (; i < root.methods.length; i++)
            if (root.methods[i].key === root.methodSetting) break;
        root.setMethod(root.methods[(i + 1) % root.methods.length].key);
    }

    // ---- Location detection (IP geolocation) ----

    property bool locating: false
    property string locateError: ""

    function detectLocation() {
        root.locating = true;
        root.locateError = "";
        root._locateProc.running = true;
    }

    property Process _locateProc: Process {
        command: ["sh", "-c",
            "curl -sf --max-time 6 https://ipinfo.io/json || curl -sf --max-time 6 'http://ip-api.com/json/?fields=status,city,regionName,country,countryCode,lat,lon,timezone'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.locating = false;
                try {
                    const d = JSON.parse(text);
                    let loc = null;
                    if (d.loc) {
                        // ipinfo.io: "loc": "lat,lon", "country": ISO code
                        const parts = d.loc.split(",");
                        loc = {
                            name: d.city || d.region || "Current location",
                            country: d.region || "",
                            countryCode: d.country || "",
                            lat: parseFloat(parts[0]),
                            lon: parseFloat(parts[1]),
                            timezone: d.timezone || ""
                        };
                    } else if (d.status === "success") {
                        loc = {
                            name: d.city || d.regionName || "Current location",
                            country: d.regionName || d.country || "",
                            countryCode: d.countryCode || "",
                            lat: d.lat,
                            lon: d.lon,
                            timezone: d.timezone || ""
                        };
                    }
                    if (loc && !isNaN(loc.lat) && !isNaN(loc.lon)) {
                        root._setLocation(loc, true);
                        return;
                    }
                } catch (e) {}
                root.locateError = "Couldn't detect location";
                // Fall back to whatever was cached last time.
                if (root.hasLocation) root._refreshOffset();
            }
        }
    }

    // ---- Manual location search (Open-Meteo geocoding) ----

    property string searchQuery: ""
    property var searchResults: []
    property bool searching: false

    property Timer _searchDebounce: Timer {
        interval: 400
        onTriggered: root._runSearch(root.searchQuery)
    }

    function search(query) {
        root.searchQuery = query;
        if (!query || query.trim().length === 0) {
            root.searchResults = [];
            root._searchDebounce.stop();
            return;
        }
        root._searchDebounce.restart();
    }

    property Process _searchProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                root.searching = false;
                try {
                    const data = JSON.parse(text);
                    root.searchResults = (data.results || []).map(r => ({
                        name: r.name,
                        country: [r.admin1, r.country].filter(s => !!s).join(", "),
                        countryCode: r.country_code || "",
                        lat: r.latitude,
                        lon: r.longitude,
                        timezone: r.timezone || ""
                    }));
                } catch (e) {
                    root.searchResults = [];
                }
            }
        }
    }

    function _runSearch(query) {
        if (!query || query.trim().length === 0) return;
        root.searching = true;
        const url = "https://geocoding-api.open-meteo.com/v1/search?count=6&language=en&name=" + encodeURIComponent(query.trim());
        root._searchProc.command = ["curl", "-s", "--max-time", "5", url];
        root._searchProc.running = true;
    }

    function chooseLocation(candidate) {
        root._setLocation(candidate, false);
        root.searchResults = [];
        root.searchQuery = "";
    }

    // ---- UTC offset of the location's timezone ----

    // Minutes east of UTC. Defaults to this machine's own offset until (or
    // unless) the location's IANA zone has been resolved.
    property int utcOffsetMinutes: -new Date().getTimezoneOffset()

    function _refreshOffset() {
        const tz = root.hasLocation ? root.location.timezone : "";
        if (!tz) {
            root.utcOffsetMinutes = -new Date().getTimezoneOffset();
            root._recompute();
            return;
        }
        root._offsetProc.environment = { TZ: tz };
        root._offsetProc.running = true;
    }

    property Process _offsetProc: Process {
        command: ["date", "+%z"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.trim().match(/^([+-])(\d\d)(\d\d)$/);
                if (m) root.utcOffsetMinutes = (m[1] === "-" ? -1 : 1) * (parseInt(m[2]) * 60 + parseInt(m[3]));
                root._recompute();
            }
        }
    }

    // ---- Prayer time calculation (PrayTimes.org v2, angle-based high-
    // latitude rule) ----

    function _dtr(d) { return d * Math.PI / 180; }
    function _rtd(r) { return r * 180 / Math.PI; }
    function _fix(a, b) { a = a - b * Math.floor(a / b); return a < 0 ? a + b : a; }

    function _julian(y, m, d) {
        if (m <= 2) { y -= 1; m += 12; }
        const A = Math.floor(y / 100);
        const B = 2 - A + Math.floor(A / 4);
        return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + d + B - 1524.5;
    }

    function _sunPosition(jd) {
        const D = jd - 2451545.0;
        const g = root._fix(357.529 + 0.98560028 * D, 360);
        const q = root._fix(280.459 + 0.98564736 * D, 360);
        const L = root._fix(q + 1.915 * Math.sin(root._dtr(g)) + 0.020 * Math.sin(root._dtr(2 * g)), 360);
        const e = 23.439 - 0.00000036 * D;
        const RA = root._rtd(Math.atan2(Math.cos(root._dtr(e)) * Math.sin(root._dtr(L)), Math.cos(root._dtr(L)))) / 15;
        return {
            eqt: q / 15 - root._fix(RA, 24),
            decl: root._rtd(Math.asin(Math.sin(root._dtr(e)) * Math.sin(root._dtr(L))))
        };
    }

    // Returns {fajr, sunrise, dhuhr, asr, maghrib, isha} as hours after UTC
    // midnight of (y, m, d) - may fall outside 0..24 at extreme longitudes,
    // which is fine since they're turned into epoch ms directly.
    function _computeDay(y, m, d, lat, lon, method, hanafi) {
        const jDate = root._julian(y, m, d) - lon / (15 * 24);

        const midDay = t => root._fix(12 - root._sunPosition(jDate + t).eqt, 24);
        const sunAngleTime = (angle, t, ccw) => {
            const decl = root._sunPosition(jDate + t).decl;
            const noon = midDay(t);
            const v = root._rtd(Math.acos(
                (-Math.sin(root._dtr(angle)) - Math.sin(root._dtr(decl)) * Math.sin(root._dtr(lat)))
                / (Math.cos(root._dtr(decl)) * Math.cos(root._dtr(lat))))) / 15;
            return noon + (ccw ? -v : v);
        };
        const asrTime = (factor, t) => {
            const decl = root._sunPosition(jDate + t).decl;
            const angle = -root._rtd(Math.atan(1 / (factor + Math.tan(root._dtr(Math.abs(lat - decl))))));
            return sunAngleTime(angle, t, false);
        };

        const riseSet = 0.833;
        const t = {
            fajr: sunAngleTime(method.fajr, 5 / 24, true),
            sunrise: sunAngleTime(riseSet, 6 / 24, true),
            dhuhr: midDay(12 / 24),
            asr: asrTime(hanafi ? 2 : 1, 13 / 24),
            sunset: sunAngleTime(riseSet, 18 / 24, false),
            maghrib: method.maghrib !== undefined ? sunAngleTime(method.maghrib, 18 / 24, false) : NaN,
            isha: method.isha !== undefined ? sunAngleTime(method.isha, 18 / 24, false) : NaN
        };
        if (isNaN(t.maghrib)) t.maghrib = t.sunset;
        if (method.ishaMinutes !== undefined) t.isha = t.maghrib + method.ishaMinutes / 60;

        // High latitudes: when twilight never reaches the angle (NaN) or
        // the result is implausibly far from sunrise/sunset, cap it at a
        // portion of the night proportional to the angle.
        const night = root._fix(t.sunrise - t.sunset, 24);
        const capped = (time, base, angle, ccw) => {
            const portion = angle / 60 * night;
            const diff = ccw ? root._fix(base - time, 24) : root._fix(time - base, 24);
            if (isNaN(time) || diff > portion) return base + (ccw ? -portion : portion);
            return time;
        };
        t.fajr = capped(t.fajr, t.sunrise, method.fajr, true);
        if (method.isha !== undefined) t.isha = capped(t.isha, t.sunset, method.isha, false);

        const out = {};
        for (const k of ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"])
            out[k] = t[k] - lon / 15;
        return out;
    }

    readonly property var prayerNames: [
        { key: "fajr", label: "Fajr" },
        { key: "sunrise", label: "Sunrise", nonPrayer: true },
        { key: "dhuhr", label: "Dhuhr" },
        { key: "asr", label: "Asr" },
        { key: "maghrib", label: "Maghrib" },
        { key: "isha", label: "Isha" }
    ]

    // [{key, label, nonPrayer, time (epoch ms)}] for the location's today.
    property var today: []
    property real tomorrowFajr: 0
    property real yesterdayIsha: 0
    property string _computedFor: ""

    function _locationDate(offsetDays) {
        const shifted = new Date(Date.now() + root.utcOffsetMinutes * 60000 + (offsetDays || 0) * 86400000);
        return { y: shifted.getUTCFullYear(), m: shifted.getUTCMonth() + 1, d: shifted.getUTCDate() };
    }

    function _timesFor(date) {
        const loc = root.location;
        const hours = root._computeDay(date.y, date.m, date.d, loc.lat, loc.lon, root.activeMethod, root.hanafi);
        const base = Date.UTC(date.y, date.m - 1, date.d);
        return root.prayerNames.map(p => ({
            key: p.key,
            label: p.label,
            nonPrayer: !!p.nonPrayer,
            time: base + hours[p.key] * 3600000
        }));
    }

    function _recompute() {
        if (!root.hasLocation) {
            root.today = [];
            root.tomorrowFajr = 0;
            root.yesterdayIsha = 0;
            root._computedFor = "";
            return;
        }
        const d = root._locationDate(0);
        root.today = root._timesFor(d);
        root.tomorrowFajr = root._timesFor(root._locationDate(1))[0].time;
        root.yesterdayIsha = root._timesFor(root._locationDate(-1))[5].time;
        root._computedFor = d.y + "-" + d.m + "-" + d.d;
    }

    // ---- Ticking / next prayer ----

    property real now: Date.now()
    property Timer _tick: Timer {
        interval: 20000
        running: true
        repeat: true
        onTriggered: {
            root.now = Date.now();
            const d = root._locationDate(0);
            if (root.hasLocation && root._computedFor !== d.y + "-" + d.m + "-" + d.d) root._refreshOffset();
        }
    }

    // {key, label, time} - first actual prayer (not sunrise) still ahead,
    // rolling over to tomorrow's Fajr after Isha.
    readonly property var next: {
        const n = root.now;
        for (const p of root.today)
            if (!p.nonPrayer && p.time > n) return p;
        if (root.tomorrowFajr > 0) return { key: "fajr", label: "Fajr", time: root.tomorrowFajr, tomorrow: true };
        return null;
    }

    // The period we're currently in, for the popup's progress bar: the
    // last event already passed (sunrise counts - it ends Fajr's window)
    // and the next one ahead, spilling into yesterday's Isha / tomorrow's
    // Fajr at either end of the day.
    readonly property var current: {
        const n = root.now;
        let c = root.yesterdayIsha > 0 ? { key: "isha", label: "Isha", time: root.yesterdayIsha } : null;
        for (const p of root.today)
            if (p.time <= n) c = p;
        return c;
    }

    readonly property var upcoming: {
        const n = root.now;
        for (const p of root.today)
            if (p.time > n) return p;
        return root.tomorrowFajr > 0 ? { key: "fajr", label: "Fajr", time: root.tomorrowFajr, tomorrow: true } : null;
    }

    readonly property real periodProgress: {
        if (!root.current || !root.upcoming) return 0;
        const span = root.upcoming.time - root.current.time;
        return span > 0 ? Math.max(0, Math.min(1, (root.now - root.current.time) / span)) : 0;
    }

    function formatTime(epochMs) {
        if (!epochMs || isNaN(epochMs)) return "--:--";
        const t = new Date(epochMs + root.utcOffsetMinutes * 60000);
        let h = t.getUTCHours();
        const mm = String(t.getUTCMinutes()).padStart(2, "0");
        const ap = h >= 12 ? "PM" : "AM";
        h = h % 12;
        if (h === 0) h = 12;
        return h + ":" + mm + " " + ap;
    }

    function formatCountdown(epochMs) {
        const mins = Math.max(0, Math.ceil((epochMs - root.now) / 60000));
        const h = Math.floor(mins / 60);
        const m = mins % 60;
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    readonly property string locationDateLabel: {
        const _dep = root.now;
        const t = new Date(Date.now() + root.utcOffsetMinutes * 60000);
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["January", "February", "March", "April", "May", "June", "July",
            "August", "September", "October", "November", "December"];
        return days[t.getUTCDay()] + ", " + months[t.getUTCMonth()] + " " + t.getUTCDate();
    }
}
