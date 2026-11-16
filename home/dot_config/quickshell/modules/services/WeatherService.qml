pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backs the world-clocks/weather section of CalendarPopup. City list (up to
// 8, name/lat/lon/IANA-timezone) persists to ~/.local/state/quickshell via
// FileView+JsonAdapter - the same "small plain state file" convention this
// dotfiles repo already uses for Neovim's theme choice. Geocoding (city
// search) and weather both go through Open-Meteo, which needs no API key.
//
// DST-aware local time doesn't need Intl or a timezone library: Open-Meteo's
// forecast response already includes `utc_offset_seconds` computed for the
// city's IANA zone at the current moment (i.e. already accounts for DST) -
// shifting Date.now() by that many seconds and reading it back with the
// UTC-based accessors gives the right wall-clock time for that city
// regardless of what timezone this machine itself is in.
QtObject {
    id: root

    readonly property int maxCities: 8

    property FileView _cityFile: FileView {
        path: Quickshell.statePath("weather-cities.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) writeAdapter();
        }
        // Fires once the city list has actually been read off disk - the
        // periodic refresh timer below has no triggeredOnStart, since at
        // startup it could race the async file load and fetch an empty list.
        onLoaded: root._refreshAll()

        adapter: JsonAdapter {
            property var cities: []
        }
    }

    readonly property var cities: root._cityFile.adapter.cities

    function _persist(list) {
        root._cityFile.adapter.cities = list;
        root._cityFile.writeAdapter();
        root._refreshAll();
    }

    function addCity(candidate) {
        const list = root.cities.slice();
        if (list.length >= root.maxCities) return false;
        list.push({
            name: candidate.name,
            country: candidate.country || "",
            admin1: candidate.admin1 || "",
            lat: candidate.lat,
            lon: candidate.lon,
            timezone: candidate.timezone || "UTC"
        });
        root._persist(list);
        root.searchResults = [];
        root.searchQuery = "";
        return true;
    }

    function removeCity(index) {
        const list = root.cities.slice();
        if (index < 0 || index >= list.length) return;
        list.splice(index, 1);
        root._persist(list);
    }

    function moveCity(index, delta) {
        const list = root.cities.slice();
        const to = index + delta;
        if (index < 0 || index >= list.length || to < 0 || to >= list.length) return;
        const item = list.splice(index, 1)[0];
        list.splice(to, 0, item);
        root._persist(list);
    }

    // ---- Geocoding search ----

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
                        country: r.country || "",
                        admin1: r.admin1 || "",
                        lat: r.latitude,
                        lon: r.longitude,
                        timezone: r.timezone || "UTC"
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

    // ---- Weather + local time per city ----

    // key -> {tempC, code, isDay, utcOffsetSeconds}
    property var weatherByKey: ({})

    function _keyFor(city) {
        return city.lat + "," + city.lon;
    }

    function weatherFor(city) {
        return root.weatherByKey[root._keyFor(city)] || null;
    }

    // Bumped every 30s purely so any binding that calls localTimeFor()
    // picks up a dependency and re-evaluates as time passes (same idiom as
    // NotificationService.relativeTime()'s `tick` read).
    property int clockTick: 0
    property Timer _clockTimer: Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.clockTick++
    }

    function localTimeFor(city) {
        const _dep = root.clockTick;
        const w = root.weatherFor(city);
        const offset = w ? w.utcOffsetSeconds : 0;
        const shifted = new Date(Date.now() + offset * 1000);
        const hh = String(shifted.getUTCHours()).padStart(2, "0");
        const mm = String(shifted.getUTCMinutes()).padStart(2, "0");
        return hh + ":" + mm;
    }

    function weatherGlyph(code) {
        if (code === 0) return "☀";
        if (code === 1 || code === 2) return "⛅";
        if (code === 3) return "☁";
        if (code === 45 || code === 48) return "🌫";
        if (code >= 51 && code <= 57) return "🌦";
        if (code >= 61 && code <= 67) return "🌧";
        if (code >= 71 && code <= 77) return "❄";
        if (code >= 80 && code <= 82) return "🌧";
        if (code === 85 || code === 86) return "❄";
        if (code >= 95) return "⛈";
        return "—";
    }

    function weatherLabel(code) {
        const table = {
            0: "Clear", 1: "Mostly clear", 2: "Partly cloudy", 3: "Overcast",
            45: "Fog", 48: "Freezing fog",
            51: "Light drizzle", 53: "Drizzle", 55: "Heavy drizzle",
            56: "Freezing drizzle", 57: "Freezing drizzle",
            61: "Light rain", 63: "Rain", 65: "Heavy rain",
            66: "Freezing rain", 67: "Freezing rain",
            71: "Light snow", 73: "Snow", 75: "Heavy snow", 77: "Snow grains",
            80: "Rain showers", 81: "Rain showers", 82: "Violent showers",
            85: "Snow showers", 86: "Snow showers",
            95: "Thunderstorm", 96: "Thunderstorm", 99: "Severe thunderstorm"
        };
        return table[code] || "—";
    }

    // Refresh queue: cities are fetched one at a time (not in parallel) to
    // keep this to a single well-behaved curl process, same pattern as the
    // rest of this shell's Process usage.
    property var _refreshQueue: []

    function _refreshAll() {
        root._refreshQueue = root.cities.slice();
        root._pumpQueue();
    }

    function _pumpQueue() {
        if (root._refreshQueue.length === 0) return;
        if (root._weatherProc.running) return;
        const city = root._refreshQueue[0];
        const url = "https://api.open-meteo.com/v1/forecast?latitude=" + city.lat
            + "&longitude=" + city.lon + "&current_weather=true&timezone="
            + encodeURIComponent(city.timezone);
        root._weatherProc.command = ["curl", "-s", "--max-time", "8", url];
        root._weatherProc._key = root._keyFor(city);
        root._weatherProc.running = true;
    }

    property Process _weatherProc: Process {
        property string _key: ""

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const cw = data.current_weather;
                    if (cw) {
                        const map = Object.assign({}, root.weatherByKey);
                        map[root._weatherProc._key] = {
                            tempC: cw.temperature,
                            code: cw.weathercode,
                            isDay: cw.is_day === 1,
                            utcOffsetSeconds: data.utc_offset_seconds || 0
                        };
                        root.weatherByKey = map;
                    }
                } catch (e) {
                    // leave any previously-cached reading in place
                }
                root._refreshQueue = root._refreshQueue.slice(1);
                root._pumpQueue();
            }
        }
    }

    property Timer _refreshTimer: Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root._refreshAll()
    }
}
