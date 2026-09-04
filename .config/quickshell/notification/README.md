# notification

It claims `org.freedesktop.Notifications` on the session bus.

Only one daemon can own that name. Stop `Dunst` (and `Mako/SwayNC` if present) before starting this Quickshell server.

## Errors?

If QML errors on OpacityMask, the import is missing or the module isn’t installed (qt6-5compat on Arch).

## urgency

notify-send -u low "Low" "quiet"
notify-send -u normal "Normal" "default"
notify-send -u critical "Critical" "stays longer / different style"

## expire timeout in ms (0 = no auto-expire, if your server honors it)

notify-send -t 3000 "Timeout" "gone in 3s"

## app name + icon

notify-send -a Firefox -i firefox "Tab crashed" "about:blank"

## actions (only if your NotificationServer has actionsSupported: true)

notify-send -A "open=Open" -A "dismiss=Dismiss" "Update ready" "Click an action"

## replace previous (same ID)

notify-send -r 42 "Volume" "50%"
notify-send -r 42 "Volume" "75%"
