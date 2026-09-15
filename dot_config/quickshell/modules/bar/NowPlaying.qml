import QtQuick
import "../../theme"
import "../common"
import "../services"

// Now-playing label, driven by MediaService (native MPRIS - any player,
// including MPD via the mpd-mpris bridge). Click opens NowPlayingPopup for
// full details and transport controls.
Pill {
    id: root

    property bool open: false

    readonly property bool hasPlayer: MediaService.hasPlayer
    readonly property string label: {
        if (!root.hasPlayer) return "Nothing playing";
        const artist = MediaService.trackArtist;
        const title = MediaService.trackTitle;
        return artist.length > 0 ? artist + " — " + title : title;
    }

    readonly property int maxTextWidth: 220

    active: root.open

    Text {
        width: Math.min(implicitWidth, root.maxTextWidth)
        elide: Text.ElideRight
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        font.bold: true
        font.italic: !root.hasPlayer
        color: root.hasPlayer ? Theme.textPrimary : Theme.textTertiary
    }

    onClicked: root.open = !root.open
}
