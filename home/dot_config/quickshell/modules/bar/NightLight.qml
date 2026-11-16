import QtQuick
import "../../theme"
import "../common"
import "../services"

// Night light toggle - see NightLightService.
Pill {
    id: root

    active: NightLightService.active

    Text {
        text: root.active ? "󰖔" : "󰖙" // nf-md-weather-night / weather-sunny (night light on/off)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: root.active ? Theme.emphasis : Theme.textPrimary
    }

    onClicked: NightLightService.toggle()
}
