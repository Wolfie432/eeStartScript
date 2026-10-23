#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# 1. Fix broken third-party repositories blocking apt-get update
rm -f /etc/apt/sources.list.d/r1soft.list
sed -i '/repo.r1soft.com/d' /etc/apt/sources.list 2>/dev/null || true

# 2. Update and install dependencies safely
apt-get update -qq
apt-get install -y -qq wget xserver-xorg-core xserver-xorg-video-dummy xserver-xorg-input-libinput x11-xserver-utils xinput dbus-x11 xfce4-session xfce4-panel xfdesktop4 xfwm4 thunar exo-utils xdg-utils pulseaudio pulseaudio-utils alsa-utils

xdg-mime default thunar.desktop inode/directory || true

# 3. Download and install Sunshine
wget -qO /tmp/s.deb https://github.com/LizardByte/Sunshine/releases/download/v2025.122.141614/sunshine-ubuntu-24.04-amd64.deb
apt-get install -y -qq /tmp/s.deb
systemctl disable --now sunshine 2>/dev/null || true

# 4. Configure Xorg Dummy Display
mkdir -p /etc/X11/xorg.conf.d /root/.config/sunshine /run/user/0
cat >/etc/X11/xorg.conf.d/20-dummy.conf <<'EOF2'
Section "Device"
Identifier "DummyDevice"
Driver "dummy"
VideoRam 256000
EndSection
Section "Monitor"
Identifier "DummyMonitor"
HorizSync 30-80
VertRefresh 50-75
Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1083 1088 1120
EndSection
Section "Screen"
Identifier "DummyScreen"
Device "DummyDevice"
Monitor "DummyMonitor"
DefaultDepth 24
SubSection "Display"
Depth 24
Modes "1920x1080"
Virtual 1920 1080
EndSubSection
EndSection
EOF2

printf 'capture = x11\nencoder = nvenc\norigin_web_ui_allowed = wan\n' >/root/.config/sunshine/sunshine.conf

# 5. Input Permissions & Runtime environment
modprobe uinput 2>/dev/null || true
[ ! -e /dev/uinput ] || chmod 666 /dev/uinput

export DISPLAY=:1 HOME=/root XDG_RUNTIME_DIR=/run/user/0 PULSE_SERVER=unix:/run/user/0/pulse/native

# 6. Start Xorg and Desktop Environment with absolute paths
/usr/bin/Xorg :1 -configdir /etc/X11/xorg.conf.d -noreset &
sleep 2

dbus-run-session -- startxfce4 &
pulseaudio --daemonize=yes --exit-idle-time=-1 || true

# 7. Setup Systemd Service
cat >/etc/systemd/system/sunshine.service <<'EOF'
[Service]
Type=simple
Environment=DISPLAY=:1 HOME=/root XDG_RUNTIME_DIR=/run/user/0 PULSE_SERVER=unix:/run/user/0/pulse/native
ExecStartPre=/bin/sh -c 'for i in $(seq 1 30); do xdpyinfo -display :1 >/dev/null 2>&1 && exit 0; sleep 1; done; exit 1'
ExecStart=/usr/bin/sunshine
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now sunshine

apt-get install -y -qq firefox