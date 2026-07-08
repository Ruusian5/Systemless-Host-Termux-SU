#!/bin/bash
# Run inside chroot as ruusian user — Full XFCE desktop
export DISPLAY=:0
export SESSION_MANAGER=localhost

# GPU — software default, HW via hwrun helper
export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe
export LIBGL_DRIVERS_PATH=/usr/lib/aarch64-linux-gnu/dri

# ── DBus session ──────────────────────────────────────────────
[ -f /tmp/dbus-env ] && . /tmp/dbus-env
if [ -z "$DBUS_SESSION_BUS_PID" ] || ! kill -0 $DBUS_SESSION_BUS_PID 2>/dev/null; then
  eval $(dbus-launch --sh-syntax)
  echo "DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" > /tmp/dbus-env
  echo "DBUS_SESSION_BUS_PID=$DBUS_SESSION_BUS_PID" >> /tmp/dbus-env
fi

# ── /dev/null workaround ──────────────────────────────────────
NULL=/tmp/.gui-null; touch "$NULL"

# ── Disable CPU-hog dbus services ─────────────────────────────
mkdir -p ~/.local/share/dbus-1/services
for f in /usr/share/dbus-1/services/org.gtk.vfs*.service; do
  echo "disabled" > ~/.local/share/dbus-1/services/$(basename $f)
done
for f in /usr/share/dbus-1/services/org.xfce.tumbler*.service; do
  echo "disabled" > ~/.local/share/dbus-1/services/$(basename $f)
done

# ── Kill known CPU hogs early ─────────────────────────────────
for p in gvfsd tumblerd gvfsd-metadata gvfs-io; do
  pkill -9 -x "$p" 2>/dev/null
done

# ── Start XFCE core daemons ───────────────────────────────────
/usr/lib/aarch64-linux-gnu/xfce4/xfconf/xfconfd 2>/dev/null &
sleep 1
xfsettingsd --daemon <"$NULL" >"$NULL" 2>&1 &

# ── Window manager (compositor OFF — Termux:X11 doesn't support it) ──
nohup xfwm4 --compositor=off --replace <"$NULL" >"$NULL" 2>&1 &

# ── Desktop manager ───────────────────────────────────────────
nohup xfdesktop <"$NULL" >"$NULL" 2>&1 &

sleep 2

# ── Dark theme config ─────────────────────────────────────────
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'GTKEOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=18
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
GTKEOF

if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
  xfconf-query -c xfwm4 -p /general/theme -s "Adwaita-dark" 2>/dev/null || true
  xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" 2>/dev/null || true
  xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark" 2>/dev/null || true
  # Disable compositor in xfconf too
  xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
fi

# ── Wallpaper via feh ─────────────────────────────────────────
if command -v feh &>/dev/null; then
  for bg in /usr/share/backgrounds/xfce/xfce-teal.jpg \
            /usr/share/backgrounds/xfce/xfce-blue.jpg \
            /usr/share/backgrounds/xfce/xfce-stripes.png; do
    if [ -f "$bg" ]; then feh --bg-fill "$bg" 2>/dev/null; break; fi
  done
fi

# ── XFCE Panel with Whisker menu ──────────────────────────────
# Remove old tint2 configs
rm -f ~/.config/tint2/tint2rc 2>/dev/null

# Pre-configure xfce4-panel for a modern look
mkdir -p ~/.config/xfce4/panel
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'PANELCFG'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="span-monitors" type="bool" value="true"/>
      <property name="size" type="uint" value="36"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
      <property name="background-style" type="int" value="1"/>
      <property name="background-alpha" type="uint" value="92"/>
      <property name="background-color" type="string" value="#1a1a2e"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator"/>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
PANELCFG

# Start xfce4-panel
nohup xfce4-panel <"$NULL" >"$NULL" 2>&1 &
PANEL_PID=$!

# ── Power manager ─────────────────────────────────────────────
nohup xfce4-power-manager <"$NULL" >"$NULL" 2>&1 &

# ── Notification daemon ───────────────────────────────────────
nohup xfce4-notifyd <"$NULL" >"$NULL" 2>&1 &

sleep 1

# ── Final cleanup ─────────────────────────────────────────────
for p in gvfsd tumblerd gvfsd-metadata gvfs-io; do
  pkill -9 -x "$p" 2>/dev/null
done

# ── Background watchdog ───────────────────────────────────────
(
  while true; do
    sleep 5
    pkill -9 -x "gvfsd" 2>/dev/null
    pkill -9 -x "tumblerd" 2>/dev/null
    pkill -9 -x "gvfsd-metadata" 2>/dev/null
  done
) &
WATCHDOG_PID=$!

echo "=== Full XFCE Desktop Ready ==="
ps aux | grep -E "xfwm4|xfdesktop|xfsettingsd|xfce4-panel" | grep -v grep

# ── Keep alive ───────────────────────────────────────────────
while true; do sleep 3600; done
