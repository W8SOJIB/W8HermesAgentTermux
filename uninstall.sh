#!/data/data/com.termux/files/usr/bin/bash
#
# =============================================================
#   ☤ W8HermesAgentTermux — Uninstaller (Termux)
#   Tool:  W8HermesAgentTermux
#   Credit: W8Team / W8SOJIB
#   Repo:  https://github.com/W8SOJIB/W8HermesAgentTermux
# =============================================================
#
# Removes everything W8HermesAgentTermux created:
#   - hermes-agent source + venv inside the proot container
#   - the ~/.local/bin/hermes launcher
#   - the PATH line added to ~/.bashrc
#   - (optional) the proot-distro container itself
#   - then deletes this uninstaller + the cloned repo folder
#
# Usage in Termux:
#   curl -fsSL https://raw.githubusercontent.com/W8SOJIB/W8HermesAgentTermux/main/uninstall.sh | bash
#

set -uo pipefail   # NOT -e: we want to tolerate missing files

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
RST='\033[0m'

export TERM="${TERM:-xterm}"
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC
: >/dev/tty 2>/dev/null && clear 2>/dev/null || true
echo -e "${CYN}=====================================================${RST}"
echo -e "${RED}       ☤ W8HermesAgentTermux UNINSTALLER ☤"
echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}   Tool: W8HermesAgentTermux | Credit: W8Team/W8SOJIB"
echo -e "${CYN}=====================================================${RST}"
echo ""

termux-wake-lock 2>/dev/null || true
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# ---- Detect the container the installer used ----
DISTRO="ubuntu"
ROOTFS_DIR="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro"
container_exists() {
    proot-distro list 2>/dev/null | grep -qiE "^[[:space:]]*\*?[[:space:]]*$1([[:space:]]|$)" && return 0
    [ -d "$ROOTFS_DIR/installed-rootfs/$1" ] && return 0
    [ -f "$ROOTFS_DIR/containers/$1/manifest.json" ] && [ -d "$ROOTFS_DIR/containers/$1/rootfs" ] && return 0
    return 1
}
for name in ubuntu ubuntu-hermes hermes2 hermes3 hermes4 hermes; do
    if container_exists "$name"; then DISTRO="$name"; break; fi
done
echo -e "${YLW}Target container: ${DISTRO}${RST}"
echo ""

# ---- Confirmation ----
echo -e "${RED}⚠️  This will DELETE the Hermes Agent inside container '${DISTRO}'.${RST}"
read -r -p "Type 'yes' to continue, anything else to cancel: " ANSWER < /dev/tty
if [ "$ANSWER" != "yes" ]; then
    echo -e "${CYN}Cancelled. Nothing was removed.${RST}"
    exit 0
fi
echo ""

# ---- 1) Remove hermes-agent + launcher + PATH inside the container ----
if [ -d "$ROOTFS_DIR/$DISTRO" ]; then
    echo -e "${CYN}🧹 Removing Hermes Agent inside ${DISTRO}...${RST}"
    proot-distro login "$DISTRO" -- bash -c '
        rm -rf "$HOME/hermes-agent"
        rm -f  "$HOME/.local/bin/hermes"
        rmdir  "$HOME/.local/bin" 2>/dev/null || true
        # drop the PATH export line we added to .bashrc
        sed -i '\''\#export PATH="$HOME/.local/bin:$PATH"#d'\'' "$HOME/.bashrc" 2>/dev/null || true
    '
fi

# ---- 2) (Optional) Remove the proot container itself ----
echo ""
echo -e "${YLW}🤖 The container '${DISTRO}' is no longer needed.${RST}"
read -r -p "Remove the whole container '${DISTRO}' too? (y/N): " RMX < /dev/tty
if [ "$RMX" = "y" ] || [ "$RMX" = "Y" ]; then
    if command -v proot-distro >/dev/null 2>&1; then
        echo -e "${CYN}🗑️ Removing proot-distro container '${DISTRO}'...${RST}"
        proot-distro remove "$DISTRO" 2>&1 || proot-distro uninstall "$DISTRO" 2>&1 || true
    else
        echo -e "${YLW}proot-distro not installed; deleting rootfs dir directly...${RST}"
        rm -rf "$ROOTFS_DIR/$DISTRO"
    fi
    [ ! -d "$ROOTFS_DIR/$DISTRO" ] && echo -e "${GRN}✅ Container removed${RST}" || echo -e "${YLW}⚠️ container dir still present (maybe you said no / not installed)${RST}"
else
    echo -e "${GRN}✅ Container kept.${RST}"
fi

# ---- 3) Delete this uninstaller + the cloned repo folder ----
echo ""
echo -e "${YLW}🗑 Cleaning up the tool files...${RST}"
REPO_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
# remove the clone we were called from (expects the repo dir)
if [ -n "$REPO_DIR" ] && [ -e "$REPO_DIR/uninstall.sh" ]; then
    echo "Removing project folder: $REPO_DIR"
    rm -rf "$REPO_DIR"
fi
# fallback: if run via curl (script in $TMPDIR or current dir is fine to leave)
rm -f "$0" 2>/dev/null || true

echo ""
echo -e "${GRN}=====================================================${RST}"
echo -e "${GRN}    ✅ W8HermesAgentTermux uninstalled successfully!"
echo -e "${GRN}=====================================================${RST}"
echo ""
echo -e "${CYN}Hermes Agent removed. Termux itself is untouched.${RST}"
echo -e "${CYN}To also remove Termux: Settings → Apps → Termux → Uninstall.${RST}"