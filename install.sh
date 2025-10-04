#!/bin/bash

# Productivity System Installer
# Sets up the complete productivity tracking system

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

PROD_HOME="${HOME}/.productivity"
BIN_DIR="${PROD_HOME}/bin"
DATA_DIR="${PROD_HOME}/data"

echo -e "${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║${NC}    🚀 Productivity System Installer                   ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check dependencies
echo -e "${BLUE}Checking dependencies...${NC}"

MISSING_DEPS=()

if ! command -v python3 &> /dev/null; then
    MISSING_DEPS+=("python3")
fi

if ! command -v git &> /dev/null; then
    MISSING_DEPS+=("git")
fi

if ! command -v gpg &> /dev/null; then
    MISSING_DEPS+=("gpg")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}Missing dependencies:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - $dep"
    done
    echo ""
    echo "Please install them first:"
    echo "  Ubuntu/Debian: sudo apt install python3 git gpg"
    echo "  macOS: brew install python3 git gpg"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"

# Install ledger if not present
echo ""
echo -e "${BLUE}Checking for ledger...${NC}"
if ! command -v ledger &> /dev/null; then
    echo -e "${YELLOW}Ledger not found. Installing...${NC}"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install ledger -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ledger
    else
        echo -e "${RED}Unable to auto-install ledger on this OS${NC}"
        echo "Please install ledger manually"
    fi
    
    if command -v ledger &> /dev/null; then
        echo -e "${GREEN}✓ Ledger installed${NC}"
    else
        echo -e "${YELLOW}⚠ Ledger installation failed (optional, continuing...)${NC}"
    fi
else
    echo -e "${GREEN}✓ Ledger already installed${NC}"
fi

echo ""

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "${PROD_HOME}"
mkdir -p "${BIN_DIR}"
mkdir -p "${DATA_DIR}"
mkdir -p "${PROD_HOME}/repo"
mkdir -p "${PROD_HOME}/.encrypted"

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Download/create scripts
echo -e "${BLUE}Installing scripts...${NC}"

# For now, we'll create placeholder files
# In real use, these would be the actual script contents

create_script() {
    local script_name=$1
    local script_content=$2
    
    echo "$script_content" > "${BIN_DIR}/${script_name}"
    chmod +x "${BIN_DIR}/${script_name}"
}

# Note: In actual implementation, you'd paste the full script contents here
# For now, creating symbolic links if scripts exist in current directory

if [ -f "./dashboard.sh" ]; then
    cp ./dashboard.sh "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/dashboard.sh"
fi

if [ -f "./habit.sh" ]; then
    cp ./habit.sh "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/habit.sh"
fi

if [ -f "./exercise.sh" ]; then
    cp ./exercise.sh "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/exercise.sh"
fi

if [ -f "./routine.sh" ]; then
    cp ./routine.sh "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/routine.sh"
fi

if [ -f "./sync.sh" ]; then
    cp ./sync.sh "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/sync.sh"
fi

echo -e "${GREEN}✓ Scripts installed${NC}"
echo ""

# Initialize data files
echo -e "${BLUE}Initializing data files...${NC}"

cat > "${DATA_DIR}/streaks.json" << 'EOF'
{
  "porn_free": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "routine": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "github": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "lives": 0,
  "max_lives": 3
}
EOF

echo '{}' > "${DATA_DIR}/habits.json"
echo '[]' > "${DATA_DIR}/exercise-log.json"

cat > "${DATA_DIR}/config.json" << 'EOF'
{
  "routine_level": 1,
  "github_username": "",
  "timezone": "America/Bogota",
  "timelog_path": "~/.productivity/data/timelog.ldg"
}
EOF

# Create empty timelog.ldg
touch "${DATA_DIR}/timelog.ldg"

echo -e "${GREEN}✓ Data files initialized${NC}"
echo ""

# Install tt script system-wide
echo -e "${BLUE}Installing tt time tracking script...${NC}"

if [ -f "${BIN_DIR}/tt.sh" ]; then
    echo "Installing tt command to /usr/bin/tt..."
    sudo cp "${BIN_DIR}/tt.sh" /usr/bin/tt
    sudo chmod 755 /usr/bin/tt
    echo -e "${GREEN}✓ tt command installed (accessible from anywhere)${NC}"
else
    echo -e "${YELLOW}⚠ tt.sh not found in bin directory${NC}"
    echo "You can add it later and run: sudo cp ~/.productivity/bin/tt.sh /usr/bin/tt"
fi

# Create timelog.ldg if it doesn't exist
if [ ! -f "${DATA_DIR}/timelog.ldg" ]; then
    touch "${DATA_DIR}/timelog.ldg"
    echo -e "${GREEN}✓ Created timelog.ldg${NC}"
fi

echo ""

# Add to PATH
echo -e "${BLUE}Setting up PATH...${NC}"

SHELL_RC="${HOME}/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="${HOME}/.zshrc"
fi

# Check if already in PATH
if ! grep -q "productivity/bin" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Productivity System
export PATH="$HOME/.productivity/bin:$PATH"

# Show dashboard on terminal open
if [[ $- == *i* ]] && [ -f "$HOME/.productivity/bin/dashboard.sh" ]; then
    bash "$HOME/.productivity/bin/dashboard.sh" quick
fi
EOF
    echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
else
    echo -e "${YELLOW}Already in PATH${NC}"
fi

echo ""

# Create command aliases
echo -e "${BLUE}Creating command aliases...${NC}"

cat > "${HOME}/.productivity/aliases.sh" << 'EOF'
#!/bin/bash
# Productivity System Aliases

alias dashboard="bash ${HOME}/.productivity/bin/dashboard.sh"
alias habit="bash ${HOME}/.productivity/bin/habit.sh"
alias exercise="bash ${HOME}/.productivity/bin/exercise.sh"
alias routine="bash ${HOME}/.productivity/bin/routine.sh"
alias sync="bash ${HOME}/.productivity/bin/sync.sh"
EOF

if ! grep -q "productivity/aliases.sh" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Productivity aliases" >> "$SHELL_RC"
    echo "source ${HOME}/.productivity/aliases.sh" >> "$SHELL_RC"
fi

echo -e "${GREEN}✓ Aliases created${NC}"
echo ""

# Installation complete
echo -e "${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║${NC}    ✨ Installation Complete! ✨                       ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Productivity System has been installed!${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo "1. Reload your shell:"
echo "   source ~/.bashrc    (or restart terminal)"
echo ""
echo "2. Set up GitHub sync (optional but recommended):"
echo "   sync setup"
echo ""
echo "3. Start tracking:"
echo "   dashboard           - View your dashboard"
echo "   habit check porn-free  - Check in for porn-free streak"
echo "   routine start morning  - Start morning routine"
echo ""
echo -e "${BOLD}Quick Reference:${NC}"
echo "  dashboard        - Show full dashboard"
echo "  habit            - Track habits and streaks"
echo "  exercise         - Log exercise routines"
echo "  routine          - Start routines with timers"
echo "  sync             - Sync across computers"
echo ""
echo -e "${YELLOW}💡 Tip: The dashboard will show automatically when you open a terminal!${NC}"
echo ""