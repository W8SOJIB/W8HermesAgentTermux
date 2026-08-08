#!/data/data/com.termux/files/usr/bin/bash
#
# =============================================================
#   ☤ W8HermesAgentTermux — Hermes Agent Installer (Termux)
#   Tool:  W8HermesAgentTermux
#   Credit: W8Team / W8SOJIB
#   Repo:  https://github.com/W8SOJIB/W8HermesAgentTermux
# =============================================================
#
# Usage in Termux:
#   curl -fsSL https://raw.githubusercontent.com/W8SOJIB/W8HermesAgentTermux/main/install.sh | bash
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
CYN='\033[0;36m'
RST='\033[0m'

# TERM may be unset when run non-interactively (curl|bash, ssh). `clear` then
# errors out under `set -e`. Export a default so ANSI output & clear always work.
export TERM="${TERM:-xterm}"
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC
: >/dev/tty 2>/dev/null && clear 2>/dev/null || true

echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}         ☤ W8HermesAgentTermux INSTALLER ☤"
echo -e "${CYN}=====================================================${RST}"
echo -e "${GRN}       Tool: W8HermesAgentTermux | Credit: W8Team/W8SOJIB"
echo -e "${CYN}=====================================================${RST}"
echo ""

# --- Termux Level Commands ---
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

echo -e "${YLW}📦 Updating Termux packages...${RST}"
# Prevent Android from killing Termux while installing
termux-wake-lock 2>/dev/null || true

# Feed 'y' from yes in case apt asks for anything despite -y
if ! yes | pkg update -y 2>&1; then
    echo -e "${YLW}⚠️  pkg update returned an error.${RST}"
    echo -e "${YLW}   Trying apt --fix-broken install...${RST}"
    apt --fix-broken install -y 2>&1 || true
    echo -e "${YLW}   Retrying pkg update...${RST}"
    yes | pkg update -y 2>&1 || true
fi

echo -e "${YLW}📦 Upgrading Termux packages...${RST}"
yes | pkg upgrade -y 2>&1 || true

echo -e "${YLW}🔧 Ensuring proot-distro is installed...${RST}"
pkg install proot-distro -y

# --- Container setup: reuse any existing one, never fail on "already exists" ---
# If a container (ubuntu, ubuntu-hermes, hermes2/3/4, ...) is already installed,
# reuse it. If creating 'ubuntu' reports "already exists", just continue.
# Detection is directory-based (the rootfs dir is proot-distro's ground truth),
# which is reliable across proot-distro versions.
DISTRO="ubuntu"
ROOTFS_DIR="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro"

# A container counts as installed if ANY of these is true:
#   1) proot-distro list shows it (authoritative, format-stable)
#   2) legacy layout: installed-rootfs/<name> exists
#   3) new layout: containers/<name>/manifest.json + rootfs exists
container_exists() {
    proot-distro list 2>/dev/null | grep -qiE "^[[:space:]]*\*?[[:space:]]*$1([[:space:]]|$)" && return 0
    [ -d "$ROOTFS_DIR/installed-rootfs/$1" ] && return 0
    [ -f "$ROOTFS_DIR/containers/$1/manifest.json" ] && [ -d "$ROOTFS_DIR/containers/$1/rootfs" ] && return 0
    return 1
}

for name in ubuntu ubuntu-hermes hermes2 hermes3 hermes4 hermes; do
    if container_exists "$name"; then
        DISTRO="$name"
        echo -e "${GRN}✅ Reusing existing container: ${name}${RST}"
        break
    fi
done

if [ "$DISTRO" = "ubuntu" ] && ! container_exists "ubuntu"; then
    echo -e "${YLW}🐧 Installing Ubuntu container (may take a few minutes)...${RST}"
    if ! proot-distro install ubuntu 2>&1; then
        echo -e "${YLW}⚠️  Container 'ubuntu' already exists or install reported an issue — reusing it.${RST}"
    fi
    echo -e "${GRN}✅ Ubuntu container ready${RST}"
fi

# Write the inner install script to a temp file to avoid quoting hell
INNER_SCRIPT=$(mktemp)
trap 'rm -f "$INNER_SCRIPT"' EXIT

cat > "$INNER_SCRIPT" << 'INNER_EOF'
#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

echo "📦 Updating Ubuntu packages..."
apt-get update -qq
apt-get upgrade -y -o Dpkg::Options::="--force-confold" >/dev/null 2>&1 || true

echo "🐍 Installing system dependencies..."
apt-get install -y -o Dpkg::Options::="--force-confold" \
    python3 python3-pip python3-venv python3-dev python-is-python3 \
    git curl wget build-essential \
    nodejs npm \
    libffi-dev libssl-dev pkg-config \
    ca-certificates >/dev/null 2>&1

# --- Auto-fix: hermes-agent requires Python >=3.11 and <3.14 ---
# Ubuntu 25.10+ ships Python 3.14, which hermes-agent rejects. Detect the
# default Python version and, if too new, install Python 3.13 automatically
# via uv standalone builds (works on any Ubuntu release, no PPA needed).
PYBIN="python3"
if "$PYBIN" -c 'import sys; sys.exit(0 if (3, 11) <= sys.version_info < (3, 14) else 1)' 2>/dev/null; then
    echo "✅ Default Python is compatible: $("$PYBIN" --version 2>&1)"
else
    echo "⚠️  hermes-agent needs Python <3.14 — installing Python 3.13 via uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || true
    export PATH="$HOME/.local/bin:$PATH"
    command -v uv >/dev/null 2>&1 || python3 -m pip install uv >/dev/null 2>&1 || true
    uv python install 3.13 >/dev/null 2>&1 || true
    PYBIN="$(uv python find 3.13 2>/dev/null || echo python3)"
    echo "✅ Using $("$PYBIN" --version 2>&1)"
fi

REPO_DIR="$HOME/hermes-agent"

# Clone or update repository
if [ -d "$REPO_DIR/.git" ]; then
    echo "🔄 Updating existing hermes-agent repository..."
    cd "$REPO_DIR"
    git fetch origin
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
    git reset --hard origin/main 2>/dev/null || git reset --hard origin/master 2>/dev/null || true
else
    echo "📥 Cloning Hermes Agent repository..."
    rm -rf "$REPO_DIR"
    git clone --depth 1 --recurse-submodules --shallow-submodules \
        https://github.com/NousResearch/hermes-agent.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Setup Python virtual environment
if [ -d "venv" ]; then
    echo "♻️  Recreating virtual environment..."
    rm -rf venv
fi

echo "🐍 Creating virtual environment..."
if command -v uv >/dev/null 2>&1; then
    uv venv --python "$PYBIN" venv || { echo "❌ venv creation failed"; exit 1; }
else
    "$PYBIN" -m venv venv || { echo "❌ venv creation failed"; exit 1; }
fi
source venv/bin/activate

# pip helper: prefer `uv pip` when uv is present.
# - The base python is uv-managed -> PEP-668 "externally managed" blocks plain pip.
# - The venv's own pip may be old and lack --break-system-packages.
# `uv pip` targets the venv directly and bypasses PEP-668 entirely (its designed use).
# NOTE: callers pass the full subcommand (e.g. `pipi install -e .`) — this wrapper
# must NOT hardcode `install` or uv will treat it as a package name.
pipi() {
    if command -v uv >/dev/null 2>&1 && [ -n "${VIRTUAL_ENV:-}" ]; then
        # activate already set $VIRTUAL_ENV; uv pip targets it, no PEP-668 issue.
        uv pip "$@"
    elif command -v uv >/dev/null 2>&1; then
        uv pip --python "$PWD/venv/bin/python" "$@"
    else
        "$PWD/venv/bin/python" -m pip --break-system-packages "$@" \
            || "$PWD/venv/bin/python" -m pip "$@"
    fi
}

echo "⬆️  Upgrading pip, setuptools, wheel..."
pipi install --upgrade pip setuptools wheel || true

echo "🔧 Installing Hermes Agent (this can take 5–10 minutes)..."
# Try extras in order of weight: [all] -> [termux] -> base.
# Output is visible so any real error shows instead of silently dying.
if ! pipi install -e ".[all]"; then
    echo "⚠️  [all] extras failed, trying [termux]..."
    if ! pipi install -e ".[termux]" -c constraints-termux.txt; then
        echo "⚠️  [termux] extras failed, trying base install..."
        if ! pipi install -e "."; then
            echo "❌ Failed to install Hermes Agent"
            echo "❌ Last error is shown above. Please share it for a fix."
            exit 1
        fi
    fi
fi

# Create a convenient launcher
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/hermes" << 'LAUNCHER_EOF'
#!/bin/bash
# Auto-generated launcher for Hermes Agent
cd "$HOME/hermes-agent"
source venv/bin/activate
exec hermes "$@"
LAUNCHER_EOF
chmod +x "$HOME/.local/bin/hermes"

# Ensure PATH includes ~/.local/bin
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "✅ Hermes Agent installed successfully inside Ubuntu!"
INNER_EOF

echo -e "${YLW}🚀 Running installation inside Ubuntu...${RST}"
echo -e "${YLW}   (This may take 5–15 minutes depending on your connection)${RST}"
echo ""

if ! proot-distro login "$DISTRO" -- bash "$INNER_SCRIPT"; then
    echo -e "${RED}❌ Installation inside Ubuntu failed${RST}"
    exit 1
fi

echo ""
echo -e "${CYN}===================================================${RST}"
echo -e "${GRN}     ✅ W8HermesAgentTermux installed successfully!"
echo -e "${CYN}===================================================${RST}"
echo ""
echo -e "${YLW}🚀 Quick Start:${RST}"
echo -e "${CYN}   proot-distro login $DISTRO${RST}"
echo -e "${CYN}   hermes setup      # Run first-time setup${RST}"
echo -e "${CYN}   hermes            # Start chatting${RST}"
echo ""
echo -e "${YLW}📖 Manual path (if hermes command not found):${RST}"
echo -e "${CYN}   proot-distro login $DISTRO${RST}"
echo -e "${CYN}   cd hermes-agent && source venv/bin/activate${RST}"
echo -e "${CYN}   hermes${RST}"
echo ""
echo -e "${GRN}💡 Need help? Visit: https://github.com/W8SOJIB/W8HermesAgentTermux${RST}"
