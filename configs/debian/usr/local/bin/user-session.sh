#!/bin/bash
# --- USER SESSION INITIALIZER (v3.2) ---
# Full XFCE desktop: xfwm4 + xfdesktop + xfce4-panel + whisker menu
# GPU: virgl HW acceleration (set by /etc/profile.d/99-hardware-acceleration.sh)

if pgrep -x "xfwm4" >/dev/null; then
    echo "An active XFCE session (xfwm4) is already running."
    echo "Exiting user-session.sh to prevent duplicate processes."
    exit 1
fi

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
GUI_NULL=/tmp/.gui-null; touch "$GUI_NULL"
export DISPLAY=:0
export SESSION_MANAGER=localhost
export LIBGL_DRIVERS_PATH=/usr/lib/aarch64-linux-gnu/dri

if [ -f /etc/profile.d/99-hardware-acceleration.sh ]; then
    . /etc/profile.d/99-hardware-acceleration.sh
fi

rm -f "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null
touch "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null
chmod 600 "$XDG_RUNTIME_DIR/ICEauthority" 2>/dev/null

export $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

for p in gvfsd tumblerd gvfsd-metadata gvfs-io xfce4-panel; do
  pkill -9 -x "$p" 2>/dev/null
done

mkdir -p /home/ruusian/.local/share/dbus-1/services
shopt -s nullglob
for f in /usr/share/dbus-1/services/org.gtk.vfs*.service; do
  echo "disabled" > /home/ruusian/.local/share/dbus-1/services/$(basename $f)
done
for f in /usr/share/dbus-1/services/org.xfce.tumbler*.service; do
  echo "disabled" > /home/ruusian/.local/share/dbus-1/services/$(basename $f)
done
shopt -u nullglob

mkdir -p /home/ruusian/.config/gtk-3.0
cat > /home/ruusian/.config/gtk-3.0/settings.ini << 'GTKEOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
GTKEOF

echo "Starting XFCE desktop (xfce4-panel + whiskermenu)..." > /home/ruusian/session_debug.log

xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false 2>/dev/null
xfconf-query -c xfwm4 -p /general/theme -s "Adwaita-dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark" 2>/dev/null || true
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark" 2>/dev/null || true

/usr/bin/xfsettingsd --daemon > "$GUI_NULL" 2>&1 &
sleep 0.5
/usr/bin/xfwm4 --compositor=off --replace > "$GUI_NULL" 2>&1 &
sleep 1
/usr/bin/xfdesktop > "$GUI_NULL" 2>&1 &

if command -v feh &>/dev/null; then
  for bg in /usr/share/backgrounds/xfce/xfce-teal.jpg \
            /usr/share/backgrounds/xfce/xfce-blue.jpg \
            /usr/share/backgrounds/xfce/xfce-stripes.png; do
    if [ -f "$bg" ]; then feh --bg-fill "$bg" 2>/dev/null; break; fi
  done
fi

mkdir -p /home/ruusian/.config/xfce4/panel
mkdir -p /home/ruusian/.config/xfce4/xfconf/xfce-perchannel-xml

cat > /home/ruusian/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'PANELCFG'
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

/usr/bin/xfce4-panel > "$GUI_NULL" 2>&1 &
PANEL_PID=$!

/usr/bin/xfce4-notifyd > "$GUI_NULL" 2>&1 &

(
  while true; do sleep 30
    pkill -9 -x "gvfsd" 2>/dev/null
    pkill -9 -x "tumblerd" 2>/dev/null
    pkill -9 -x "gvfsd-metadata" 2>/dev/null
    pkill -9 -x "xfce4-power-manager" 2>/dev/null
  done
) &
WATCHDOG_PID=$!

sleep 2
for _comp in xfwm4 xfsettingsd xfdesktop xfce4-panel; do
    if pgrep -x "$_comp" >/dev/null 2>&1; then
        echo "  + $_comp running" >> /home/ruusian/session_debug.log
    else
        echo "  - $_comp FAILED" >> /home/ruusian/session_debug.log
    fi
done
echo "=== Full XFCE Desktop Ready ===" >> /home/ruusian/session_debug.log

while true; do sleep 3600; done
