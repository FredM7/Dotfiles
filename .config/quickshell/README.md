# Quickshell help

Docs here:

https://quickshell.org/docs

---

Install Quickshell:

```sh
sudo pacman -S quickshell
```

Run the taskbar:

PS: you may not need the `QT_QPA_PLATFORM=wayland` if you added it in your `hyprland envs`.

```sh
QT_QPA_PLATFORM=wayland qs -c taskbar
# OR
QT_QPA_PLATFORM=wayland quickshell -c taskbar
# OR
qs -c taskbar
# OR
quickshell -c taskbar
```
