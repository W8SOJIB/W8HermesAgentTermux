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

clear

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
DISTRO="ubuntu"

for name in ubuntu ubuntu-hermes hermes2 hermes3 hermes4 hermes; do
    if proot-distro list 2>/dev/null | grep -iE "^[[:space:]]*$name([[:space:]]|$)" | grep -qiE "yes|installed"; then
        DISTRO="$name"
        echo -e "${GRN}✅ Reusing existing container: ${name}${RST}"
        break
    fi
done

if [ "$DISTRO" = "ubuntu" ]; then
    echo -e "${YLW}🐧 Checking Ubuntu container...${RST}"
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

python3 -m venv venv
source venv/bin/activate

echo "⬆️  Upgrading pip, setuptools, wheel..."
python3 -m pip install --upgrade pip setuptools wheel >/dev/null 2>&1

echo "🔧 Installing Hermes Agent (this can take 5–10 minutes)..."
# Try the official full extras first, fall back to base install
if ! python3 -m pip install -e ".[all]" >/dev/null 2>&1; then
    echo "⚠️  Full extras install failed, trying base install..."
    if ! python3 -m pip install -e "."; then
        echo "❌ Failed to install Hermes Agent"
        exit 1
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
