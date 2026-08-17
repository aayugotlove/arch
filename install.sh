#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Aayu Hyprland Dotfiles Installer
# ============================================================

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${USER:-$(id -un)}"
HOME_DIR="$HOME"

# -----------------------------
# Colors / UI
# -----------------------------
BOLD='\033[1m'
RESET='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
DIM='\033[2m'

info()    { printf "${CYAN}==>${RESET} %s\n" "$*"; }
ok()      { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}!${RESET} %s\n" "$*"; }
error()   { printf "${RED}✗${RESET} %s\n" "$*" >&2; }
section() { printf "\n${BOLD}${CYAN}%s${RESET}\n" "$*"; }

spinner() {
    local pid="$1"
    local msg="$2"
    local chars='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${CYAN}%s${RESET} %s" "${chars:i++%4:1}" "$msg"
        sleep 0.1
    done
    printf "\r\033[K"
}

run_with_spinner() {
    local msg="$1"
    shift
    "$@" >/tmp/aayu-installer.log 2>&1 &
    local pid=$!
    spinner "$pid" "$msg"
    if wait "$pid"; then
        ok "$msg"
    else
        error "$msg failed."
        error "See /tmp/aayu-installer.log for details."
        return 1
    fi
}

# -----------------------------
# Banner
# -----------------------------
clear
cat <<'EOF'

 █████╗  █████╗ ██╗   ██╗██╗   ██╗
██╔══██╗██╔══██╗╚██╗ ██╔╝██║   ██║
███████║███████║ ╚████╔╝ ██║   ██║
██╔══██║██╔══██║  ╚██╔╝  ██║   ██║
██║  ██║██║  ██║   ██║   ╚██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝

        HYPRLAND DOTFILES INSTALLER

EOF

printf "Repository: %s\n" "$REPO_DIR"
printf "User:       %s\n" "$USER_NAME"
printf "Home:       %s\n\n" "$HOME_DIR"

# -----------------------------
# Checks
# -----------------------------
if [[ ! -f /etc/arch-release ]]; then
    error "This installer supports Arch Linux only."
    exit 1
fi
ok "Arch Linux detected."

if [[ "$EUID" -eq 0 ]]; then
    error "Do not run this installer as root."
    exit 1
fi

if [[ ! -d "$REPO_DIR/config" ]]; then
    error "config/ directory not found in $REPO_DIR"
    exit 1
fi

# -----------------------------
# Components
# -----------------------------
section "Installation Components"

cat <<'EOF'
  1) Core Hyprland environment
  2) Theming & customization
  3) Audio / PipeWire
  4) Thunar & file management
  5) System utilities
  6) Extra utilities
  7) Optional applications
  8) AUR packages
  9) Everything
  0) Quit
EOF

echo
echo "Multiple selections are allowed: 123456"
read -r -p "Choose components [1-9]: " SELECTION

[[ "$SELECTION" == "0" ]] && exit 0

if [[ "$SELECTION" == "9" ]]; then
    SELECTION="12345678"
fi

if [[ ! "$SELECTION" =~ ^[1-8]+$ ]]; then
    error "Invalid selection."
    exit 1
fi

has() { [[ "$SELECTION" == *"$1"* ]]; }

# -----------------------------
# Waybar is optional
# -----------------------------
INSTALL_WAYBAR="n"

if has 1 && [[ -d "$REPO_DIR/config/waybar" ]]; then
    echo
    warn "Waybar detected in this dotfiles repository."
    cat <<'EOF'
Your configuration contains Waybar files.

If Waybar is not installed:
  • Waybar modules will not work.
  • Your Waybar configuration will simply remain unused.
EOF
    read -r -p "Install Waybar? [y/N]: " INSTALL_WAYBAR
fi

# -----------------------------
# Selection summary
# -----------------------------
echo
printf "${BOLD}╭────────────────────────────────────────────╮${RESET}\n"
printf "${BOLD}│ Selected components                        │${RESET}\n"
printf "${BOLD}╰────────────────────────────────────────────╯${RESET}\n"

has 1 && ok "Core Hyprland"
has 2 && ok "Theming & customization"
has 3 && ok "Audio / PipeWire"
has 4 && ok "Thunar & file management"
has 5 && ok "System utilities"
has 6 && ok "Extra utilities"
has 7 && ok "Optional applications"
has 8 && ok "AUR packages"

if [[ "$INSTALL_WAYBAR" =~ ^[Yy]$ ]]; then
    ok "Waybar"
else
    warn "Waybar will NOT be installed."
fi

echo
warn "The installer backs up existing ~/.config entries before replacing them."
warn "Wallpaper files are NOT installed; put your wallpapers in ~/wals/."
echo

read -r -p "Continue installation? [Y/n]: " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && exit 0

# -----------------------------
# Package lists
# -----------------------------
CORE_PKGS=(
    hyprland hypridle hyprlock
    kitty foot rofi swaync awww
    wl-clipboard cliphist grim slurp imv mpv
    polkit-gnome
    xdg-desktop-portal xdg-desktop-portal-hyprland
    cava btop quickshell
)

THEME_PKGS=(
    matugen nwg-look adw-gtk-theme
)

AUDIO_PKGS=(
    alsa-card-profiles alsa-lib alsa-ucm-conf
    alsa-firmware alsa-plugins alsa-tools alsa-topology-conf
    pipewire pipewire-audio pipewire-alsa pipewire-pulse
    pipewire-jack pipewire-session-manager wireplumber
    pavucontrol libpipewire libpulse libwireplumber
    portaudio webrtc-audio-processing-1
)

THUNAR_PKGS=(
    thunar tumbler gvfs gvfs-mtp
)

SYSTEM_PKGS=(
    networkmanager bluez bluez-utils
    brightnessctl power-profiles-daemon
    smartmontools imagemagick curl wget
)

EXTRA_PKGS=(
    nautilus baobab rnote
    android-tools
    gnome-clocks gnome-calculator
)

OPTIONAL_PKGS=(
    zsh git
)

REPO_PKGS=()

has 1 && REPO_PKGS+=("${CORE_PKGS[@]}")
has 2 && REPO_PKGS+=("${THEME_PKGS[@]}")
has 3 && REPO_PKGS+=("${AUDIO_PKGS[@]}")
has 4 && REPO_PKGS+=("${THUNAR_PKGS[@]}")
has 5 && REPO_PKGS+=("${SYSTEM_PKGS[@]}")
has 6 && REPO_PKGS+=("${EXTRA_PKGS[@]}")
has 7 && REPO_PKGS+=("${OPTIONAL_PKGS[@]}")

if [[ "$INSTALL_WAYBAR" =~ ^[Yy]$ ]]; then
    REPO_PKGS+=(waybar)
fi

# De-duplicate packages while preserving order.
mapfile -t REPO_PKGS < <(printf '%s\n' "${REPO_PKGS[@]}" | awk '!seen[$0]++')

# -----------------------------
# Install repo packages
# -----------------------------
if ((${#REPO_PKGS[@]})); then
    section "Installing repository packages..."
    sudo pacman -Syu --needed "${REPO_PKGS[@]}"
    ok "Repository packages installed."
fi

# -----------------------------
# paru bootstrap
# -----------------------------
if has 8; then
    section "Checking paru..."

    if command -v paru >/dev/null 2>&1; then
        ok "paru is already installed."
    else
        warn "paru is not installed. Building it from the AUR..."
        sudo pacman -S --needed base-devel git
        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_DIR"' EXIT

        git clone https://aur.archlinux.org/paru.git "$TMP_DIR/paru"
        (
            cd "$TMP_DIR/paru"
            makepkg -si --noconfirm
        )
        ok "paru installed."
    fi
fi

# -----------------------------
# AUR packages
# -----------------------------
if has 8; then
    AUR_PKGS=(
        hyprshade
        papirus-folders
        bibata-cursor-theme-bin
    )

    section "Installing AUR packages..."
    if paru -S --needed "${AUR_PKGS[@]}"; then
        ok "AUR packages installed."
    else
        warn "One or more AUR packages failed to install."
        warn "Continuing with the rest of the installation."
    fi
fi

# -----------------------------
# Oh My Zsh + plugins + P10k
# -----------------------------
if has 7; then
    section "Configuring Zsh"

    if ! command -v zsh >/dev/null 2>&1; then
        error "zsh is not installed. Select component 7."
        exit 1
    fi

    ZSH_DIR="$HOME_DIR/.oh-my-zsh"
    ZSH_CUSTOM="${ZSH_DIR}/custom"

    if [[ -d "$ZSH_DIR" ]]; then
        ok "Oh My Zsh already installed."
    else
        run_with_spinner "Cloning Oh My Zsh..." \
            git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
    fi

    mkdir -p "$ZSH_CUSTOM/plugins"

    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        ok "zsh-autosuggestions already installed."
    else
        run_with_spinner "Installing zsh-autosuggestions..." \
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]]; then
        ok "fast-syntax-highlighting already installed."
    else
        run_with_spinner "Installing fast-syntax-highlighting..." \
            git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting \
            "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    fi

    P10K_DIR="$HOME_DIR/.powerlevel10k"

    if [[ -d "$P10K_DIR/.git" ]]; then
        ok "Powerlevel10k already installed."
    elif [[ -e "$P10K_DIR" ]]; then
        warn "$P10K_DIR exists but is not a git clone; leaving it untouched."
    else
        run_with_spinner "Cloning Powerlevel10k..." \
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    fi

    ok "Zsh environment configured."
fi

# -----------------------------
# Config installation
# -----------------------------
backup_path() {
    local src="$1"
    local backup="${src}.backup"

    if [[ -e "$src" || -L "$src" ]]; then
        rm -rf "$backup"
        mv "$src" "$backup"
        printf "  ${DIM}Backed up:${RESET} %s\n" "$src"
        printf "       ${DIM}to:${RESET} %s\n" "$backup"
    fi
}

install_config_tree() {
    local src="$1"
    local dest="$2"

    [[ -d "$src" ]] || return 0

    backup_path "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
}

if [[ -d "$REPO_DIR/config" ]]; then
    section "Installing configuration files..."

    while IFS= read -r -d '' item; do
        name="$(basename "$item")"

        # Waybar is intentionally skipped when the user declined it.
        if [[ "$name" == "waybar" && ! "$INSTALL_WAYBAR" =~ ^[Yy]$ ]]; then
            continue
        fi

        install_config_tree "$item" "$HOME_DIR/.config/$name"
    done < <(find "$REPO_DIR/config" -mindepth 1 -maxdepth 1 -print0)

    ok "~/.config installed."
fi

# -----------------------------
# Local scripts
# -----------------------------
if [[ -d "$REPO_DIR/local/bin" ]]; then
    section "Installing local scripts..."
    mkdir -p "$HOME_DIR/.local/bin"

    while IFS= read -r -d '' file; do
        name="$(basename "$file")"

        # Keep the user's existing special "code" launcher untouched.
        if [[ "$name" == "code" ]]; then
            warn "Skipping local/bin/code"
            continue
        fi

        dest="$HOME_DIR/.local/bin/$name"
        backup_path "$dest"
        install -m 755 "$file" "$dest"
    done < <(find "$REPO_DIR/local/bin" -maxdepth 1 -type f -print0)

    ok "~/.local/bin installed."
fi

# -----------------------------
# .zshrc
# -----------------------------
if has 7 && [[ -f "$REPO_DIR/.zshrc" ]]; then
    section "Installing .zshrc..."
    backup_path "$HOME_DIR/.zshrc"
    cp "$REPO_DIR/.zshrc" "$HOME_DIR/.zshrc"
    ok ".zshrc installed."
fi

# -----------------------------
# Services
# -----------------------------
if has 3; then
    section "Enabling audio services..."
    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
    ok "PipeWire / WirePlumber enabled."
fi

if has 5; then
    section "Enabling system services..."
    sudo systemctl enable --now NetworkManager.service
    sudo systemctl enable --now bluetooth.service
    ok "NetworkManager / Bluetooth configured."
fi

# -----------------------------
# Default shell
# -----------------------------
if has 7 && command -v zsh >/dev/null 2>&1; then
    echo
    read -r -p "Set Zsh as your default shell? [Y/n]: " SET_ZSH
    if [[ ! "$SET_ZSH" =~ ^[Nn]$ ]]; then
        ZSH_PATH="$(command -v zsh)"
        if [[ "$SHELL" != "$ZSH_PATH" ]]; then
            chsh -s "$ZSH_PATH"
        fi
        ok "Zsh is now your default shell."
    fi
fi

# -----------------------------
# Final
# -----------------------------
echo
printf "${BOLD}╭────────────────────────────────────────────╮${RESET}\n"
printf "${BOLD}│          INSTALLATION COMPLETE             │${RESET}\n"
printf "${BOLD}╰────────────────────────────────────────────╯${RESET}\n\n"

ok "Aayu Hyprland dotfiles installed."

cat <<EOF

Next steps:

  1. Put wallpapers in:
     ~/wals/

  2. Run:
     aayufy

  3. Matugen will generate colors from the
     wallpaper selected by aayufy.

  4. Restart Hyprland or log out/in.

EOF

if [[ "$INSTALL_WAYBAR" =~ ^[Yy]$ ]]; then
    ok "Waybar was installed."
else
    warn "Waybar was NOT installed."
    echo "  Your Waybar configuration remains in the repository,"
    echo "  but no Waybar process/modules will run."
fi

has 3 && ok "PipeWire and WirePlumber are enabled."

echo
echo "Default terminals supported by the configuration: foot + kitty"

if has 7; then
    cat <<'EOF'

Zsh:
  • Oh My Zsh
  • zsh-autosuggestions
  • fast-syntax-highlighting
  • Powerlevel10k (Git clone)
EOF
fi

if has 8; then
    cat <<'EOF'

AUR:
  • hyprshade
  • papirus-folders
  • bibata-cursor-theme-bin
EOF
fi

echo
printf "${GREEN}Enjoy your Aayu Hyprland setup.${RESET}\n"
