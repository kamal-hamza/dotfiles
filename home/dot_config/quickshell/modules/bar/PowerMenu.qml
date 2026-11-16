import "../../theme"
import "../common"

// Body shown from the power button: Lock / Logout / Suspend / Reboot /
// Shutdown. The action list itself (including the destructive-action
// confirm behavior) lives in modules/common/PowerActions.qml, shared with
// the launcher's PowerMode so both stay in sync.
PopupCard {
    id: popup

    cardWidth: 200

    PowerActions {
        width: parent.width
    }
}
