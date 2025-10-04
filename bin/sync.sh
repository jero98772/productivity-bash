#!/bin/bash

# Sync System
# Synchronize productivity data across multiple computers via GitHub

PROD_HOME="${HOME}/.productivity"
DATA_DIR="${PROD_HOME}/data"
REPO_DIR="${PROD_HOME}/repo"
ENCRYPTED_DIR="${PROD_HOME}/.encrypted"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Get encryption password
get_password() {
    local pass_file="${HOME}/.productivity-key"
    
    if [ -f "$pass_file" ]; then
        cat "$pass_file"
    else
        echo ""
    fi
}

# Encrypt data
encrypt_data() {
    local password=$(get_password)
    
    if [ -z "$password" ]; then
        echo -e "${RED}Error: No encryption password set${NC}"
        echo "Run 'sync setup' first"
        return 1
    fi
    
    mkdir -p "${ENCRYPTED_DIR}"
    
    # Encrypt each data file (JSON files)
    for file in "${DATA_DIR}"/*.json; do
        if [ -f "$file" ]; then
            local basename=$(basename "$file")
            echo "$password" | gpg --batch --yes --passphrase-fd 0 \
                --symmetric --cipher-algo AES256 \
                --output "${ENCRYPTED_DIR}/${basename}.gpg" \
                "$file" 2>/dev/null
        fi
    done
    
    # Encrypt timelog.ldg from data directory
    if [ -f "${DATA_DIR}/timelog.ldg" ]; then
        echo "$password" | gpg --batch --yes --passphrase-fd 0 \
            --symmetric --cipher-algo AES256 \
            --output "${ENCRYPTED_DIR}/timelog.ldg.gpg" \
            "${DATA_DIR}/timelog.ldg" 2>/dev/null
    fi
}

# Decrypt data
decrypt_data() {
    local password=$(get_password)
    
    if [ -z "$password" ]; then
        echo -e "${RED}Error: No encryption password set${NC}"
        return 1
    fi
    
    if [ ! -d "${ENCRYPTED_DIR}" ]; then
        return 0
    fi
    
    # Decrypt each file
    for file in "${ENCRYPTED_DIR}"/*.gpg; do
        if [ -f "$file" ]; then
            local basename=$(basename "$file" .gpg)
            
            # All files go to data directory now
            echo "$password" | gpg --batch --yes --passphrase-fd 0 \
                --decrypt \
                --output "${DATA_DIR}/${basename}" \
                "$file" 2>/dev/null
        fi
    done
}

# Push to GitHub
push_data() {
    local silent=${1:-""}
    
    [ "$silent" != "silent" ] && echo -e "${BLUE}Syncing to GitHub...${NC}"
    
    # Encrypt first
    encrypt_data || return 1
    
    # Check if repo exists
    if [ ! -d "${REPO_DIR}/.git" ]; then
        if [ "$silent" != "silent" ]; then
            echo -e "${RED}Error: Git repository not initialized${NC}"
            echo "Run 'sync setup' first"
        fi
        return 1
    fi
    
    cd "${REPO_DIR}"
    
    # Copy encrypted files to repo
    cp -r "${ENCRYPTED_DIR}"/* . 2>/dev/null
    
    # Add and commit
    git add -A >/dev/null 2>&1
    
    if git diff --staged --quiet; then
        [ "$silent" != "silent" ] && echo "No changes to sync"
        return 0
    fi
    
    local hostname=$(hostname)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    git commit -m "Auto-sync from ${hostname} at ${timestamp}" >/dev/null 2>&1
    git push origin main >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        [ "$silent" != "silent" ] && echo -e "${GREEN}✓ Synced to GitHub${NC}"
    else
        [ "$silent" != "silent" ] && echo -e "${YELLOW}⚠ Push failed (will retry later)${NC}"
    fi
}

# Pull from GitHub
pull_data() {
    local silent=${1:-""}
    
    [ "$silent" != "silent" ] && echo -e "${BLUE}Pulling from GitHub...${NC}"
    
    if [ ! -d "${REPO_DIR}/.git" ]; then
        [ "$silent" != "silent" ] && echo "No repo configured, skipping pull"
        return 0
    fi
    
    cd "${REPO_DIR}"
    
    # Stash any local changes
    git stash >/dev/null 2>&1
    
    # Pull latest
    git pull origin main >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        # Copy encrypted files back
        mkdir -p "${ENCRYPTED_DIR}"
        cp *.gpg "${ENCRYPTED_DIR}/" 2>/dev/null
        
        # Decrypt
        decrypt_data
        
        [ "$silent" != "silent" ] && echo -e "${GREEN}✓ Synced from GitHub${NC}"
    else
        [ "$silent" != "silent" ] && echo -e "${YELLOW}⚠ Pull failed${NC}"
    fi
}

# Setup sync
setup_sync() {
    echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}    🔧 Productivity Sync Setup         ${BOLD}║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get GitHub repo URL
    echo "Enter your GitHub repository URL:"
    echo "(e.g., git@github.com:username/productivity-data.git)"
    read -p "URL: " repo_url
    
    if [ -z "$repo_url" ]; then
        echo -e "${RED}Error: Repository URL required${NC}"
        return 1
    fi
    
    # Get encryption password
    echo ""
    echo "Enter encryption password (this will be stored locally):"
    read -s password
    echo ""
    echo "Confirm password:"
    read -s password2
    echo ""
    
    if [ "$password" != "$password2" ]; then
        echo -e "${RED}Error: Passwords don't match${NC}"
        return 1
    fi
    
    # Save password
    echo "$password" > "${HOME}/.productivity-key"
    chmod 600 "${HOME}/.productivity-key"
    
    # Clone or init repo
    if [ -d "${REPO_DIR}" ]; then
        rm -rf "${REPO_DIR}"
    fi
    
    echo ""
    echo "Cloning repository..."
    
    git clone "$repo_url" "${REPO_DIR}" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "Repository doesn't exist or is empty, creating new..."
        mkdir -p "${REPO_DIR}"
        cd "${REPO_DIR}"
        git init >/dev/null 2>&1
        git remote add origin "$repo_url" >/dev/null 2>&1
        
        # Create README
        cat > README.md << 'EOF'
# Productivity Data (Encrypted)

This repository contains encrypted productivity tracking data.
All files are encrypted with GPG before being committed.

**Do not share your encryption password!**
EOF
        
        git add README.md
        git commit -m "Initial commit" >/dev/null 2>&1
        git branch -M main >/dev/null 2>&1
        git push -u origin main >/dev/null 2>&1
    fi
    
    echo ""
    echo -e "${GREEN}✓ Sync setup complete!${NC}"
    echo ""
    echo "Your data will now sync automatically."
    echo "Encryption password saved to: ~/.productivity-key"
    echo ""
    echo "To sync on another computer:"
    echo "  1. Install this system"
    echo "  2. Run 'sync setup' with the same repo URL and password"
    echo ""
}

# Show sync status
show_status() {
    echo -e "${BOLD}📊 Sync Status${NC}"
    echo "═══════════════════════════════════════════════════════"
    
    if [ -f "${HOME}/.productivity-key" ]; then
        echo -e "Encryption: ${GREEN}✓ Configured${NC}"
    else
        echo -e "Encryption: ${RED}✗ Not configured${NC}"
    fi
    
    if [ -d "${REPO_DIR}/.git" ]; then
        echo -e "Repository: ${GREEN}✓ Configured${NC}"
        
        cd "${REPO_DIR}"
        local remote=$(git remote get-url origin 2>/dev/null)
        echo "Remote URL: $remote"
        
        local last_commit=$(git log -1 --format="%cd" --date=relative 2>/dev/null)
        echo "Last sync: $last_commit"
        
        # Check if there are uncommitted changes
        if git diff --quiet && git diff --staged --quiet; then
            echo -e "Status: ${GREEN}Up to date${NC}"
        else
            echo -e "Status: ${YELLOW}Changes pending${NC}"
        fi
    else
        echo -e "Repository: ${RED}✗ Not configured${NC}"
        echo ""
        echo "Run 'sync setup' to configure"
    fi
    
    echo ""
}

# Force sync (push and pull)
force_sync() {
    echo -e "${BOLD}🔄 Force Sync${NC}"
    echo ""
    
    pull_data
    push_data
    
    echo ""
    echo -e "${GREEN}Sync complete!${NC}"
}

# Main command handler
case "${1}" in
    push)
        push_data "${2}"
        ;;
    
    pull)
        pull_data "${2}"
        ;;
    
    setup)
        setup_sync
        ;;
    
    status)
        show_status
        ;;
    
    force)
        force_sync
        ;;
    
    *)
        cat << 'EOF'
Sync System Commands:

  sync setup       - Setup GitHub synchronization
  sync push        - Push data to GitHub
  sync pull        - Pull data from GitHub
  sync force       - Force full sync (pull + push)
  sync status      - Show sync status

Examples:
  sync setup
  sync push
  sync pull

EOF
        ;;
esac

exit 0