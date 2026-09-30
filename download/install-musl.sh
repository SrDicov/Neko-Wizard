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
        bluetooth printer amd intel \
        gufw
}

# ------------------------------------------------------------------------------
# arxy backend (Arch compat layer) for gaming apps with no musl build.
# Official Arch packages install as root (pkexec, GUI prompt); AUR -bin ones
# MUST run as the invoking user (makepkg forbids root, arxy elevates itself
# via sudo/doas for its root part).
# ------------------------------------------------------------------------------

ensure_arxy() {
    if ! command -v arxy >/dev/null 2>&1; then
        log "Installing arxy (Arch compat layer, one time)..."
        pkexec xbps-install -Sy arxy || die "Could not install arxy (needs z-repo-musl)"
    fi
    if [[ ! -x /var/lib/arxy/root/usr/bin/pacman ]]; then
        log "Setting up arxy image (one-time download)..."
        pkexec arxy setup || die "arxy setup failed"
    fi
    # [multilib] for lib32-* deps (same sed arxy uses; idempotent).
    pkexec bash -c 'grep -q "^\[multilib\]" /var/lib/arxy/root/etc/pacman.conf 2>/dev/null || sed -i -E "/^#\[multilib\]/,/^#?Include/s/^#//" /var/lib/arxy/root/etc/pacman.conf' \
        || die "Could not enable multilib in arxy"
}

arxy_official() { # <pkg...> : Arch official repos (needs root)
    ensure_arxy
    log "Installing $* via arxy (Arch official)..."
    pkexec arxy install "$@" || die "arxy install failed"
}

arxy_aur() { # <pkg> : AUR -bin, builds as user (arxy elevates itself)
    ensure_arxy
    log "Installing $1 via arxy (AUR)..."
    as_user arxy install --aur "$1" || die "arxy AUR install failed (needs working sudo/doas for the user)"
}

# ------------------------------------------------------------------------------
# Gaming
# ------------------------------------------------------------------------------

install_steam() {
    # mesa/vulkan-icd-loader are optdepends of steam: explicit for GL + 32-bit.
    arxy_official steam mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader
}

install_portproton() {
    arxy_aur portproton
}

install_heroic() {
    arxy_aur heroic-games-launcher-bin
}

install_lutris() {
    # wine is optdepend of lutris: explicit, without it nothing runs.
    arxy_official lutris wine
}

install_hytale() {
    arxy_aur hytale-launcher-bin
}

install_trinity() {
    # Native package from z-repo-musl.
    log "Installing Trinity Launcher..."
    pkexec xbps-install -Sy trinity-launcher-ap
}

install_prismlauncher() {
    arxy_official prismlauncher
}

install_pineconemc() {
    # Ely.by fork (PineconeMC upstream); -bin build per arxy AUR policy.
    arxy_aur elyprismlauncher-bin
}

install_protonup() {
    arxy_aur protonup-qt-bin
}

install_faugus() {
    arxy_aur faugus-launcher-bin
}

# ------------------------------------------------------------------------------
# Audio & Video editing
# ------------------------------------------------------------------------------

install_reaper() {
    # Arch official build (verified in extra).
    arxy_official reaper
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
    # Musl: proprietary client only exists as AUR; via arxy (as user).
    arxy_aur spotify
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
    # AUR -bin build (verified).
    arxy_aur brave-origin-bin
}

install_helium_browser() {
    # AUR -bin build (verified).
    arxy_aur helium-browser-bin
}

install_librewolf() {
    # Arch official build (verified in extra).
    arxy_official librewolf
}

install_zen_browser() {
    # AUR -bin build (verified).
    arxy_aur zen-browser-bin
}

# ------------------------------------------------------------------------------
# Text editing and documents
# ------------------------------------------------------------------------------

install_onlyoffice() {
    # AUR -bin build (verified).
    arxy_aur onlyoffice-bin
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
