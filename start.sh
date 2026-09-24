
#!/bin/bash

set -e

# Start DBus
service dbus start

# Start PulseAudio
pulseaudio --start --system --disallow-exit --disable-shm || true

# Prepare X11 socket
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Start XRDP
service xrdp start

# Keep container alive and show XRDP logs
tail -F /var/log/xrdp/xrdp.log /var/log/xrdp/xrdp-sesman.log
