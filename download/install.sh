#!/usr/bin/env bash
# ==============================================================================
#  Neko-Wizard installer
#  download/install.sh
#
#  Single source of truth for every application / driver that Neko-Wizard can
#  install. Each app is a function; the dispatcher at the bottom maps an
#  app-id to its function.
#
#  After a push to `main` this file lives at:
#    https://raw.githubusercontent.com/Neko-Void-Linux/Neko-Wizard/main/download/install.sh
#
#  Usage:
#    bash install.sh <app-id>     install one application
#    bash install.sh list         print all available app-ids
#    bash install.sh help         show this help
#
#  Exit status is 0 on success, non-zero on failure so Neko-Wizard can report
#  the result. Every step logs a line prefixed with [neko] to stdout; the app
#  shows those lines in its progress label.
# ==============================================================================

set -u

# Single-prompt batch mode: the app runs `pkexec bash install.sh id1 id2...`
# once, so nested pkexec calls become no-ops and user-level tasks drop back
# to the invoking user instead of landing in /root.
if [ "$(id -u)" = 0 ]; then
    pkexec() { "$@"; }
    # ponytail: awk-on-/etc/passwd ceiling — no getent on musl; assumes
    # polkit launch, a raw root shell without PKEXEC_UID runs user tasks as root.
    _USER_HOME="$(awk -F: -v u="${PKEXEC_UID:-0}" '$3==u{print $6; exit}' /etc/passwd)"
    [ -n "$_USER_HOME" ] || _USER_HOME="$HOME"
    as_user() { runuser -u "#${PKEXEC_UID:-0}" -- env HOME="$_USER_HOME" "$@"; }
else
    as_user() { "$@"; }
fi

log() { printf '[neko] %s\n' "$*"; }
die() { printf '[neko] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    printf 'Neko-Wizard installer\n\n'
    printf 'Usage: bash %s <app-id>\n' "$0"
    printf '       bash %s list\n\n' "$0"
    printf 'Run "bash %s list" to see every available app-id.\n' "$0"
}

list_apps() {
    log "Available app-ids:"
    printf '  %s\n' \
        steam portproton heroic lutris hytale trinity prismlauncher pineconemc protonup faugus \
        reaper obs kdenlive openshot vlc audacity ardour blender \
        krita gimp inkscape \
        spotify vesktop waterfox brave zerotierone telegram vivaldi chromium \
        brave-origin helium-browser librewolf zen-browser \
        onlyoffice kate libreoffice \
        bluetooth printer amd intel nvidia-open nvidia-latest nvidia-580 nvidia-470 nvidia-390 \
        gufw
}

# ------------------------------------------------------------------------------
# Gaming
# ------------------------------------------------------------------------------

install_steam() {
    log "Installing Steam (void-repo-nonfree + multilib + 32bit libs)..."
    pkexec xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree \
        && pkexec xbps-install -Sy steam-udev-rules MangoHud gamescope libGL-32bit libpulseaudio-32bit libtxc_dxtn-32bit \
        mesa mesa-dri mesa-vulkan-radeon vulkan-loader mesa-32bit  libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit steam-bin
}

install_portproton() {
    log "Installing PortProton..."
    pkexec xbps-install -Sy portproton-bin
}

install_heroic() {
    log "Installing Heroic Games Launcher..."
    pkexec xbps-install -Sy heroic-games-bin
}

install_lutris() {
    log "Installing Lutris..."
    pkexec xbps-install -Sy lutris
}

install_hytale() {
    log "Installing Hytale..."
    pkexec xbps-install -Sy hytale-installer
}

install_trinity() {
    # Same package name on Helix and Musl (user-provided repo).
    log "Installing Trinity Launcher..."
    pkexec xbps-install -Sy trinity-launcher-ap
}

install_prismlauncher() {
    log "Installing PrismLauncher..."
    pkexec xbps-install -Sy PrismLauncher
}

install_pineconemc() {
    log "Installing PineconeMC..."
    pkexec xbps-install -Sy pineconemc-bin
}

install_protonup() {
    log "Installing ProtonUp-Qt..."
    pkexec xbps-install -Sy protonup-qt
}

install_faugus() {
    log "Installing Faugus Launcher..."
    pkexec xbps-install -Sy faugus-launcher
}

# ------------------------------------------------------------------------------
# Audio & Video editing
# ------------------------------------------------------------------------------

install_reaper() {
    log "Installing Reaper..."
    pkexec xbps-install -Sy reaper-bin
}

install_obs() {
    log "Installing OBS Studio..."
    pkexec xbps-install -Sy obs
}

install_kdenlive() {
    log "Installing Kdenlive..."
    pkexec xbps-install -Sy kdenlive
}

install_openshot() {
    log "Installing OpenShot..."
    pkexec xbps-install -Sy openshot
}

install_vlc() {
    log "Installing VLC..."
    pkexec xbps-install -Sy vlc
}

install_audacity() {
    log "Installing Audacity..."
    pkexec xbps-install -Sy audacity
}

install_ardour() {
    log "Installing Ardour..."
    pkexec xbps-install -Sy ardour
}

install_blender() {
    log "Installing Blender..."
    pkexec xbps-install -Sy blender
}

# ------------------------------------------------------------------------------
# Drawing and Image editing
# ------------------------------------------------------------------------------

install_krita() {
    log "Installing Krita..."
    pkexec xbps-install -Sy krita
}

install_gimp() {
    log "Installing GIMP..."
    pkexec xbps-install -Sy gimp
}

install_inkscape() {
    log "Installing Inkscape..."
    pkexec xbps-install -Sy inkscape
}

# ------------------------------------------------------------------------------
# Social apps and Internet
# ------------------------------------------------------------------------------

install_spotify() {
    # Helix: user-provided xbps package (not in official repos).
    log "Installing Spotify..."
    pkexec xbps-install -Sy spotify
}

install_vesktop() {
    log "Installing Vesktop..."
    pkexec xbps-install -Sy vesktop-bin
}

install_waterfox() {
    log "Installing Waterfox..."
    pkexec xbps-install -Sy waterfox-bin
}

install_brave() {
    log "Installing Brave Browser..."
    pkexec xbps-install -Sy brave-bin
}

install_zerotierone() {
    log "Installing ZeroTier One..."
    pkexec xbps-install -Sy zerotierone
}

install_telegram() {
    log "Installing Telegram..."
    pkexec xbps-install -Sy telegram-desktop
}

install_vivaldi() {
    log "Installing Vivaldi..."
    pkexec xbps-install -Sy vivaldi
}

install_chromium() {
    log "Installing Chromium..."
    pkexec xbps-install -Sy chromium
}

install_brave_origin() {
    log "Installing Brave Origin..."
    pkexec xbps-install -Sy brave-origin-bin
}

install_helium_browser() {
    log "Installing Helium Browser..."
    pkexec xbps-install -Sy helium-browser-bin
}

install_librewolf() {
    log "Installing LibreWolf..."
    pkexec xbps-install -Sy librewolf-bin
}

install_zen_browser() {
    log "Installing Zen Browser..."
    pkexec xbps-install -Sy zen-browser-bin
}

# ------------------------------------------------------------------------------
# Text editing and documents
# ------------------------------------------------------------------------------

install_onlyoffice() {
    log "Installing OnlyOffice..."
    pkexec xbps-install -Sy onlyoffice-bin
}

install_kate() {
    log "Installing Kate..."
    pkexec xbps-install -Sy kate
}

install_libreoffice() {
    log "Installing LibreOffice..."
    pkexec xbps-install -Sy libreoffice
}

# Invoking user even inside the single-pkexec batch (where $USER is root).
_real_user() { if [ -n "${PKEXEC_UID:-}" ]; then id -nu "$PKEXEC_UID"; else id -nu; fi; }

# ------------------------------------------------------------------------------
# Drivers (each one pulls all its related packages)
# ------------------------------------------------------------------------------

install_bluetooth() {
    log "Enabling Bluetooth support..."
    # Pinned sha (no floating main); ln -sf + drop redundant `sv up` so a
    # second run doesn't die on the existing /var/service link.
    curl -fsSL -o /tmp/bluetooth-enable.sh https://raw.githubusercontent.com/Neko-Void-Linux/bluetooth-enabler/ac110dc3b861/install.sh \
        && sed -i 's|^ln -s |ln -sf |; /^sv up /d' /tmp/bluetooth-enable.sh \
        && pkexec bash /tmp/bluetooth-enable.sh
}

install_printer() {
    log "Enabling Printer support..."
    # Pinned sha. Upstream `usermod $USER` hits root under pkexec, so the
    # real invoking user is added here (idempotent).
    curl -fsSL -o /tmp/printer-enable.sh https://raw.githubusercontent.com/Neko-Void-Linux/printer-enable/e57adc50612c/enable.sh \
        && pkexec bash /tmp/printer-enable.sh \
        && pkexec usermod -a -G lpadmin "$(_real_user)"
}

install_amd() {
    log "Installing AMD drivers..."
    pkexec xbps-install -Sy mesa-dri mesa-dri-32bit mesa-vulkan-radeon mesa-vulkan-radeon-32bit linux-firmware-amd
}

install_intel() {
    log "Installing Intel drivers..."
    pkexec xbps-remove -y libva-intel-driver intel-video-accel
    pkexec xbps-install -Sy mesa-dri mesa-dri-32bit mesa-vulkan-intel mesa-vulkan-intel-32bit libva-intel-driver-irql linux-firmware-intel intel-media-driver mesa-intel-dri-32bit mesa-intel-dri
}

# Función auxiliar para descargar el repositorio de nvidia-support
download_nvidia_support() {
    log "Downloading NVIDIA support scripts..."
    # Pinned sha (dir name carries the sha, resolved dynamically). Grub file
    # is overwritten downstream, so keep one backup (never overwrite it).
    curl -fsSL -o /tmp/nvidia-support.tar.gz https://github.com/Neko-Void-Linux/nvidia-support/archive/1e1ac7bafdbf.tar.gz \
        && NVIDIR="/tmp/$(tar -tzf /tmp/nvidia-support.tar.gz | head -1 | cut -d/ -f1)" \
        && tar -xzf /tmp/nvidia-support.tar.gz -C /tmp/ \
        && { [ -e /etc/default/grub.neko-bak ] || pkexec cp -a /etc/default/grub /etc/default/grub.neko-bak; }
}

install_nvidia_open() {
    download_nvidia_support
    log "Installing NVIDIA (open kernel modules)..."
    pkexec bash "$NVIDIR/install.sh" open
}

install_nvidia_latest() {
    download_nvidia_support
    log "Installing NVIDIA (proprietary, latest)..."
    pkexec bash "$NVIDIR/install.sh" latest
}

install_nvidia_580() {
    download_nvidia_support
    log "Installing NVIDIA (proprietary, 580 series)..."
    pkexec bash "$NVIDIR/install.sh" 580
}

install_nvidia_470() {
    download_nvidia_support
    log "Installing NVIDIA (proprietary, 470 series)..."
    pkexec bash "$NVIDIR/install.sh" 470
}

install_nvidia_390() {
    download_nvidia_support
    log "Installing NVIDIA (proprietary, 390 series)..."
    pkexec bash "$NVIDIR/install.sh" 390
}


# ------------------------------------------------------------------------------
# Security
# ------------------------------------------------------------------------------

install_gufw() {
    log "Installing UFW + GUFW firewall..."
    pkexec xbps-install -Sy ufw gufw \
        && pkexec ln -s /etc/sv/ufw /var/service/ \
        && pkexec ufw enable
}

# ------------------------------------------------------------------------------
# Dispatcher
# ------------------------------------------------------------------------------

install_one() { # <app-id>, exit status = success/failure
case "${1:-}" in
    steam)         install_steam ;;
    portproton)    install_portproton ;;
    heroic)        install_heroic ;;
    lutris)        install_lutris ;;
    hytale)        install_hytale ;;
    trinity)       install_trinity ;;
    prismlauncher) install_prismlauncher ;;
    pineconemc)    install_pineconemc ;;
    protonup)      install_protonup ;;
    faugus)        install_faugus ;;

    reaper)        install_reaper ;;
    obs)           install_obs ;;
    kdenlive)      install_kdenlive ;;
    openshot)      install_openshot ;;
    vlc)           install_vlc ;;
    audacity)      install_audacity ;;
    ardour)        install_ardour ;;
    blender)       install_blender ;;

    krita)         install_krita ;;
    gimp)          install_gimp ;;
    inkscape)      install_inkscape ;;

    spotify)       install_spotify ;;
    vesktop)       install_vesktop ;;
    waterfox)      install_waterfox ;;
    brave)         install_brave ;;
    zerotierone)   install_zerotierone ;;
    telegram)      install_telegram ;;
    vivaldi)       install_vivaldi ;;
    chromium)      install_chromium ;;
    brave-origin)  install_brave_origin ;;
    helium-browser) install_helium_browser ;;
    librewolf)     install_librewolf ;;
    zen-browser)   install_zen_browser ;;

    onlyoffice)    install_onlyoffice ;;
    kate)          install_kate ;;
    libreoffice)   install_libreoffice ;;

    bluetooth)     install_bluetooth ;;
    printer)       install_printer ;;
    amd)           install_amd ;;
    intel)         install_intel ;;
    nvidia-open)   install_nvidia_open ;;
    nvidia-latest) install_nvidia_latest ;;
    nvidia-580)    install_nvidia_580 ;;
    nvidia-470)    install_nvidia_470 ;;
    nvidia-390)    install_nvidia_390 ;;

    gufw)          install_gufw ;;

    list)          list_apps; exit 0 ;;
    help|-h|--help) usage; exit 0 ;;
    "")            die "Missing app-id. Usage: $0 <app-id>... (or '$0 list' to see the available ids)" ;;
    *)             die "Unknown app-id: '$1'. Run '$0 list' to see the available ids." ;;
esac
}

case "${1:-}" in
    list|help|-h|--help) install_one "$1" ;;
    "")            die "Missing app-id. Usage: $0 <app-id>... (or '$0 list' to see the available ids)" ;;
    __single)      install_one "${2:-}"; exit "$?" ;;
esac

# Batch: one pkexec session covers every id; markers keep the per-app report.
fails=0
for APP in "$@"; do
    if ( install_one "$APP" ); then
        printf '[neko] NEKO_OK %s\n' "$APP"
    else
        printf '[neko] NEKO_FAIL %s\n' "$APP"
        fails=$((fails + 1))
    fi
done
if [ "$fails" -ne 0 ]; then
    printf '[neko] %s installation(s) failed.\n' "$fails" >&2
    exit 1
fi
