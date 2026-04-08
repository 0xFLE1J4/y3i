#!/bin/bash

# Script d'installation i3wm complet - Version corrigée et optimisée
# Testé sur Debian 12 / Ubuntu 22.04+

set -e  # Arrêt sur erreur
set -u  # Erreur sur variable non définie

# Récupération du chemin absolu du script (robuste)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérification du dossier de configuration
if [ ! -d ".config" ]; then
    echo_error "Dossier .config non trouvé dans $SCRIPT_DIR"
    exit 1
fi

echo_info "Mise à jour et installation des paquets systèmes..."
sudo apt-get update
sudo apt-get install -y arandr flameshot arc-theme feh i3blocks i3status i3 i3-wm \
    lxappearance python3-pip python3-venv rofi unclutter cargo papirus-icon-theme \
    imagemagick libxcb-shape0-dev libxcb-keysyms1-dev libpango1.0-dev \
    libxcb-util0-dev libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev \
    libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev \
    libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev \
    libxcb-xrm0 libxcb-xrm-dev autoconf meson libxcb-render-util0-dev \
    libxcb-shape0-dev libxcb-xfixes0-dev picom alacritty unzip xdotool

# Installation de Rust (officiel) et des dépendances pour la compilation
echo_info "Installation des dépendances de compilation..."
sudo apt-get install -y libpipewire-0.3-dev pkg-config clang libdbus-1-dev 



echo_info "Installation de Rust via rustup..."
# Le flag '-y' à la fin permet une installation automatisée sans intervention utilisateur
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Chargement de l'environnement Rust dans le script courant
source "$HOME/.cargo/env"

# Installation des outils Cargo modernes
echo_info "Installation des outils Cargo (wiremix, impala, bluetui)..."
cargo install wiremix impala bluetui

# Création du dossier fonts et installation
echo_info "Installation de la police Iosevka..."
mkdir -p ~/.local/share/fonts/
if [ -f "$SCRIPT_DIR/fonts/Iosevka.zip" ]; then
    unzip -qo "$SCRIPT_DIR/fonts/Iosevka.zip" -d ~/.local/share/fonts/
    fc-cache -fv
else
    echo_warn "Fichier $SCRIPT_DIR/fonts/Iosevka.zip introuvable, étape ignorée."
fi

# Installation pywal
echo_info "Installation de pywal..."
if command -v pip3 &> /dev/null; then
    pip3 install --user pywal --break-system-packages 2>/dev/null || pip3 install --user pywal
else
    echo_error "pip3 n'est pas installé."
fi

# Création des dossiers de configuration
echo_info "Création de l'arborescence de configuration..."
mkdir -p ~/.config/{i3,rofi,alacritty,picom,i3blocks}
mkdir -p ~/.local/share/yi3/{keybinding,wallpaper,script}

# Copie des fichiers de configuration
echo_info "Copie des fichiers de configuration (avec sauvegarde des existants)..."
CP_OPT="--backup=numbered"

cp $CP_OPT .config/i3/config ~/.config/i3/config
cp $CP_OPT .config/i3blocks/i3blocks.conf ~/.config/i3blocks/i3blocks.conf
cp $CP_OPT .config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
cp $CP_OPT .config/rofi/config.rasi ~/.config/rofi/config.rasi
cp $CP_OPT .config/picom/picom.conf ~/.config/picom/picom.conf

# Copie des scripts yi3 (sécurisée en cas de dossiers vides/manquants)
if [ -d "$SCRIPT_DIR/setup/yi3" ]; then
    cp $CP_OPT "$SCRIPT_DIR"/setup/yi3/keybinding/*.conf ~/.local/share/yi3/keybinding/ 2>/dev/null || true
    cp $CP_OPT "$SCRIPT_DIR"/setup/yi3/script/*.sh ~/.local/share/yi3/script/ 2>/dev/null || true
    cp $CP_OPT "$SCRIPT_DIR"/setup/yi3/wallpaper/* ~/.local/share/yi3/wallpaper/ 2>/dev/null || true
else
    echo_warn "Dossier $SCRIPT_DIR/setup/yi3 introuvable, fichiers yi3 non copiés."
fi

# rendre les scripts executables
chmod +x ~/.local/share/yi3/script/* 2>/dev/null || true

echo ""
echo_info "═══════════════════════════════════════════════════════════"
echo_info "Installation terminée avec succès!"
echo_info "═══════════════════════════════════════════════════════════"
echo ""
echo_info "Prochaines étapes:"
echo "  1. Assurez-vous que le dossier Cargo est dans votre PATH :"
echo "     Ajoutez: export PATH=\"\$HOME/.cargo/bin:\$PATH\" à votre .bashrc ou .zshrc"
echo "  2. Choisir un wallpaper et exécuter: pywal -i /path/to/image"
echo "  3. Éditer ~/.fehbg pour définir le wallpaper au démarrage"
echo "  4. Redémarrer votre système"
echo "  5. Sélectionner 'i3' sur l'écran de connexion"
echo "  6. Lancer 'lxappearance' et sélectionner 'Arc-Dark'"
echo ""
echo_info "Configuration terminée! Profitez de votre nouvel environnement i3wm!"