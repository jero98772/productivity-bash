#!/bin/bash

# Quick Start Script
# Get up and running with the productivity system in minutes

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

clear

cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🚀  PRODUCTIVITY SYSTEM - QUICK START  🚀               ║
║                                                              ║
║   Transform your daily routine with:                         ║
║   • Habit tracking & streaks 🔥                             ║
║   • Morning study blocks 📚                                 ║
║   • Exercise logging 🏋️                                     ║
║   • Multi-device sync 🔄                                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${BOLD}This will set up your complete productivity system.${NC}"
echo ""
read -p "Ready to start? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Step 1: Check dependencies
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 1/5: Checking dependencies${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MISSING=()

check_cmd() {
    if command -v $1 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $1"
    else
        echo -e "  ${RED}✗${NC} $1 ${YELLOW}(missing)${NC}"
        MISSING+=("$1")
    fi
}

check_cmd python3
check_cmd git
check_cmd gpg

if [ ${#MISSING[@]} -ne 0 ]; then
    echo ""
    echo -e "${RED}Missing required dependencies!${NC}"
    echo ""
    echo "Please install:"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  sudo apt install ${MISSING[@]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install ${MISSING[@]}"
    fi
    
    exit 1
fi

echo -e "\n${GREEN}All dependencies found!${NC}"
sleep 1

# Step 2: Create directory structure
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 2/5: Creating directory structure${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

PROD_HOME="${HOME}/.productivity"

if [ -d "$PROD_HOME" ]; then
    echo -e "${YELLOW}Productivity directory already exists.${NC}"
    read -p "Overwrite? This will DELETE existing data! (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Backing up to ~/.productivity.backup..."
        mv "$PROD_HOME" "${HOME}/.productivity.backup.$(date +%s)"
    else
        echo "Setup cancelled."
        exit 0
    fi
fi

echo "Creating directories..."
mkdir -p "${PROD_HOME}"/{bin,data,repo,.encrypted}
echo -e "${GREEN}✓ Directory structure created${NC}"
sleep 1

# Step 3: Install scripts
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 3/5: Installing scripts${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo -e "${YELLOW}You need to save the following scripts to ${PROD_HOME}/bin/${NC}"
echo ""
echo "Required scripts:"
echo "  • dashboard.sh  - Main dashboard"
echo "  • habit.sh      - Habit tracking"
echo "  • exercise.sh   - Exercise logger"
echo "  • routine.sh    - Routine scheduler"
echo "  • sync.sh       - Sync system"
echo ""
echo "Copy these files from where you saved them, then press Enter..."
read -p ""

# Check if scripts were copied
SCRIPTS_OK=true
for script in dashboard.sh habit.sh exercise.sh routine.sh sync.sh; do
    if [ ! -f "${PROD_HOME}/bin/${script}" ]; then
        echo -e "${RED}✗ Missing: ${script}${NC}"
        SCRIPTS_OK=false
    else
        chmod +x "${PROD_HOME}/bin/${script}"
        echo -e "${GREEN}✓ Found: ${script}${NC}"
    fi
done

if [ "$SCRIPTS_OK" = false ]; then
    echo ""
    echo -e "${RED}Not all scripts found. Please copy them and run this again.${NC}"
    exit 1
fi

# Step 4: Configure shell
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 4/5: Configuring shell${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SHELL_RC="${HOME}/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="${HOME}/.zshrc"
fi

echo "Detected shell config: $SHELL_RC"

# Create aliases
cat > "${PROD_HOME}/aliases.sh" << 'EOF'
#!/bin/bash
# Productivity System Aliases
alias dashboard="bash ${HOME}/.productivity/bin/dashboard.sh"
alias habit="bash ${HOME}/.productivity/bin/habit.sh"
alias exercise="bash ${HOME}/.productivity/bin/exercise.sh"
alias routine="bash ${HOME}/.productivity/bin/routine.sh"
alias sync="bash ${HOME}/.productivity/bin/sync.sh"
alias tt="bash ${HOME}/.productivity/bin/tt.sh"

EOF

# Add to shell rc if not present
if ! grep -q "productivity/bin" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# ===== Productivity System =====
export PATH="$HOME/.productivity/bin:$PATH"
source "$HOME/.productivity/aliases.sh"

# Show quick dashboard on terminal open
if [[ $- == *i* ]] && [ -f "$HOME/.productivity/bin/dashboard.sh" ]; then
    bash "$HOME/.productivity/bin/dashboard.sh" quick
fi
EOF
    echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
else
    echo -e "${YELLOW}Already configured in $SHELL_RC${NC}"
fi

# Step 5: Initialize
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 5/5: Initializing data${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

bash "${PROD_HOME}/bin/dashboard.sh" >/dev/null 2>&1 || true

echo -e "${GREEN}✓ Data files initialized${NC}"

# Complete!
echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║${NC}                ${GREEN}✨ Setup Complete! ✨${NC}                      ${GREEN}${BOLD}║${NC}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}What's Next?${NC}"
echo ""
echo "1️⃣  Reload your shell:"
echo "   ${CYAN}source ~/.bashrc${NC}  (or restart terminal)"
echo ""
echo "2️⃣  View your dashboard:"
echo "   ${CYAN}dashboard${NC}"
echo ""
echo "3️⃣  Set up GitHub sync (optional):"
echo "   ${CYAN}sync setup${NC}"
echo ""
echo "4️⃣  Start tracking:"
echo "   ${CYAN}habit check porn-free${NC}     - Start your porn-free streak"
echo "   ${CYAN}routine start morning${NC}     - Begin morning routine"
echo "   ${CYAN}exercise log pushups${NC}      - Log exercise"
echo ""
echo -e "${BOLD}Quick Commands:${NC}"
echo "  ${CYAN}dashboard${NC}  - View stats"
echo "  ${CYAN}habit${NC}      - Track habits"
echo "  ${CYAN}exercise${NC}   - Log workouts"
echo "  ${CYAN}routine${NC}    - Start routines"
echo "  ${CYAN}sync${NC}       - Sync data"
echo ""
echo -e "${YELLOW}💡 Your dashboard will show automatically when you open a terminal!${NC}"
echo ""
echo -e "Questions? Check ${CYAN}README.md${NC} for the complete guide."
echo ""
echo -e "${GREEN}Good luck on your productivity journey! 🚀${NC}"
echo ""