FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Enable 32-bit packages for Wine
RUN dpkg --add-architecture i386

# Update package lists and install desktop + XRDP environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xrdp \
        xorgxrdp \
        xfce4 \
        xfce4-goodies \
        xorg \
        dbus-x11 \
        sudo \
        curl \
        wget \
        nano \
        net-tools \
        policykit-1 \
        pulseaudio \
        pulseaudio-utils \
        wine \
        wine32 \
        firefox-esr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root" | chpasswd

# Allow Xorg to be started by XRDP
RUN if [ -f /etc/X11/Xwrapper.config ]; then \
        sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
    else \
        mkdir -p /etc/X11 && \
        echo "allowed_users=anybody" > /etc/X11/Xwrapper.config; \
    fi

# XFCE session for root
RUN echo "startxfce4" > /root/.xsession && \
    chmod 700 /root/.xsession

# Generate DBus machine ID
RUN mkdir -p /var/run/dbus && \
    dbus-uuidgen --ensure=/etc/machine-id && \
    ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Configure XRDP
RUN sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/^security_layer=.*/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    printf '%s\n' '#!/bin/sh' 'exec startxfce4' > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Allow XRDP to access its TLS certificates
RUN adduser xrdp ssl-cert

# Startup script
#COPY start.sh /start.sh
# RUN chmod +x /start.sh

# XRDP port
# EXPOSE 3389

# CMD ["/start.sh"]

COPY start.sh /start.sh

RUN sed -i 's/\r$//' /start.sh && \
    chmod +x /start.sh

EXPOSE 3389

CMD ["/bin/bash", "/start.sh"]
