#!/data/data/com.termux/files/usr/bin/bash

# Set strict error handling
set -u

# ==========================================
# 🚀 TERMUX-INIT-GIT: STEP 3/3 - GIT CLONE & SSH SERVICE
# ==========================================

LOG="$HOME/git-ssh-setup.log"
REPO_SSH="git@github.com:android-research/termux-namp.git"
DEST="$HOME"
AUTH_KEYS_SRC="$DEST/app/production/ssh/authorized_keys"
AUTH_KEYS_DEST="$HOME/.ssh/authorized_keys"
SSH_SERVICE_SCRIPT="$DEST/scripts/services/ssh-service.sh"
RETRIES=5

echo "📝 Starting setup: $(date)" > "$LOG"

log() {
    echo "$1" | tee -a "$LOG"
}

# ==========================================
# SCRIPT SUMMARY & CONFIRMATION
# ==========================================

show_summary() {
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║        🚀 TERMUX-INIT-GIT: STEP 3/3 - GIT CLONE     "
    echo "║          Repository Clone & SSH Service Setup      "
    echo "╠═══════════════════════════════════════════════════╣"
    echo "║ 📋 SUMMARY OF WHAT WILL BE DONE:                   "
    echo "║                                                    "
    echo "║ 🔐 1. SSH Connection Verification                  "
    echo "║     • Verify GitHub SSH access via port 443        "
    echo "║     • Start SSH agent and load keys                "
    echo "║     • Test authentication with GitHub              "
    echo "║                                                    "
    echo "║ 📦 2. Repository Cloning                           "
    echo "║     • Clone: android-research/termux-namp         "
    echo "║     • Setup repo contents in home directory       "
    echo "║                                                   "
    echo "║ 🔧 3. SSH Configuration                           "
    echo "║     • Configure ~/.ssh directory & permissions    "
    echo "║     • Add GitHub to known_hosts                   "
    echo "║     • Setup authorized_keys from repository       "
    echo "║                                                   "
    echo "║ 🚀 4. SSH Service Setup                           "
    echo "║     • Install SSH service daemon                  "
    echo "║     • Start SSH service for remote access         "
    echo "║                                                    "
    echo "║ ⚠️  PREREQUISITES (from Step 2/3):                 "
    echo "║     • SSH public key must be added to GitHub       "
    echo "║     • SSH key generated from previous step         "
    echo "║                                                    "
    echo "║ 📍 LOG FILE: ~/git-ssh-setup.log                   "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
}

confirm_setup() {
    echo "⚠️  IMPORTANT: Make sure you have completed Step 2/3 and added your SSH public key to GitHub!"
    echo ""
    echo "🔗 Add your SSH key as a deploy key at:"
    echo "   https://github.com/android-research/termux-namp/settings/keys"
    echo ""
    while true; do
        printf "Do you want to proceed with the repository clone and SSH service setup? (Y/n): "
        read -r REPLY
        echo
        case $REPLY in
            [Yy]* | "" )
                echo "✅ Proceeding with git clone and SSH service setup..."
                echo ""
                break
                ;;
            [Nn]* )
                echo "❌ Setup cancelled by user."
                exit 0
                ;;
            * )
                echo "Please answer y (yes) or n (no), or press Enter for yes."
                ;;
        esac
    done
}

# ==========================================
# MAIN SETUP FUNCTIONS
# ==========================================

retry_ssh_check() {
    local attempt=1
    log "🔍 Testing SSH connection to GitHub via port 443..."
    
    # Use verbose SSH connection for debugging
    until ssh -T -v -p 443 git@ssh.github.com 2>&1 | tee -a "$LOG" | grep -E "(successfully authenticated|You've successfully authenticated)" > /dev/null; do
        if (( attempt >= RETRIES )); then
            log "❌ Failed to authenticate with GitHub after $RETRIES attempts."
            log "💡 Make sure your SSH key is added as a deploy key to the repository."
            log "💡 You can test manually with: ssh -T -v -p 443 git@ssh.github.com"
            
            # Show last SSH attempt for debugging
            log "🔍 Last SSH attempt output:"
            ssh -T -v -p 443 git@ssh.github.com 2>&1 | tail -10 | tee -a "$LOG"
            exit 1
        fi
        log "⏳ GitHub auth not ready. Retrying ($attempt/$RETRIES)..."
        sleep 5
        ((attempt++))
    done
    log "✅ SSH auth with GitHub successful."
}

setup_ssh_agent() {
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║         🔐 STEP 1: SSH CONNECTION VERIFICATION     "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
    log "🔐 Verifying GitHub SSH access..."

    # Ensure SSH agent is running and keys are loaded
    if [ -z "${SSH_AUTH_SOCK:-}" ]; then
        log "🚀 Starting SSH agent..."
        eval "$(ssh-agent -s)" | tee -a "$LOG"
        
        # Export the SSH_AUTH_SOCK for current shell
        export SSH_AUTH_SOCK
        export SSH_AGENT_PID
    fi

    # Add any SSH keys in ~/.ssh to the agent (with better error handling)
    for key in ~/.ssh/id_*; do
        if [ -f "$key" ] && [ ! "${key##*.}" = "pub" ]; then
            log "🔑 Adding key to SSH agent: $key"
            if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK:-}" ]; then
                ssh-add "$key" 2>&1 | tee -a "$LOG"
            else
                log "⚠️ SSH agent not available, skipping key addition"
            fi
        fi
    done

    retry_ssh_check
    log "✅ SSH connection verification complete."
    echo ""
}

clone_repository() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           📦 STEP 2: REPOSITORY CLONING            "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
    if [ -d "$DEST/.git" ]; then
        log "⚠️ Repository already exists at $DEST/.git"
        echo ""
        while true; do
            printf "Do you want to re-download the repository? This will remove existing files (y/N): "
            read -r REPLY
            echo
            case $REPLY in
                [Yy]* )
                    log "🗑️ Removing existing repository files..."
                    
                    # List of repository files and directories to remove
                    REPO_ITEMS=(
                        ".git"
                        ".gitignore"
                        ".gitconfig"
                        ".bash_profile"
                        ".p10k.zsh"
                        ".zshrc"
                        "app"
                        "docs"
                        "resources"
                        "scripts"
                        "www"
                        "README.md"
                        "TODO.md"
                        "ISSUES.md"
                        "SETUP.md"
                    )
                    
                    # Remove repository items
                    for item in "${REPO_ITEMS[@]}"; do
                        if [[ "$item" == file_list_*.txt ]]; then
                            # Handle wildcard pattern for file_list files
                            rm -rf "$DEST"/file_list_*.txt 2>/dev/null || true
                        else
                            if [ -e "$DEST/$item" ]; then
                                log "  • Removing: $item"
                                rm -rf "$DEST/$item" 2>/dev/null || true
                            fi
                        fi
                    done
                    
                    log "✅ Existing repository files removed, proceeding with fresh clone..."
                    break
                    ;;
                [Nn]* | "" )
                    log "✅ Keeping existing repository, skipping clone."
                    echo ""
                    return 0
                    ;;
                * )
                    echo "Please answer y (yes) or n (no), or press Enter for no."
                    ;;
            esac
        done
    fi
    
    log "📦 Cloning repo contents to $DEST (with trace logging)..."
    # Create a temporary directory for cloning in a writable location
    TEMP_CLONE="$HOME/temp-clone-$$"
    
    # Clean up any existing temp directory
    rm -rf "$TEMP_CLONE"
    
    GIT_TRACE=1 GIT_SSH_COMMAND="ssh -v -p 443" git clone "$REPO_SSH" "$TEMP_CLONE" 2>&1 | tee -a "$LOG"

    if [ $? -eq 0 ] && [ -d "$TEMP_CLONE" ]; then
        log "📁 Moving repository contents to $DEST..."
        # Move all contents including .git to HOME
        cd "$TEMP_CLONE"
        mv .* * "$DEST/" 2>/dev/null
        cd "$HOME"
        rmdir "$TEMP_CLONE" 2>/dev/null
        log "✅ Repository cloned successfully to $DEST"
    else
        log "❌ Clone failed - check network connection and SSH key setup"
        log "💡 Verify your deploy key is added to: https://github.com/android-research/termux-namp/settings/keys"
        rm -rf "$TEMP_CLONE"
        exit 1
    fi
    log "✅ Repository cloning complete."
    echo ""
}

configure_ssh() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           🔧 STEP 3: SSH CONFIGURATION             "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
    log "📁 Ensuring ~/.ssh exists..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Add GitHub to known_hosts if not already present
    if ! grep -q "ssh.github.com" ~/.ssh/known_hosts 2>/dev/null; then
        log "🔑 Adding GitHub (ssh.github.com:443) to known_hosts..."
        ssh-keyscan -p 443 -t rsa,dsa,ecdsa,ed25519 ssh.github.com >> ~/.ssh/known_hosts 2>/dev/null
    fi

    if [ -f "$AUTH_KEYS_SRC" ]; then
        log "🔑 Appending authorized_keys from repo..."
        touch "$AUTH_KEYS_DEST"
        cat "$AUTH_KEYS_SRC" >> "$AUTH_KEYS_DEST"
        sort -u "$AUTH_KEYS_DEST" -o "$AUTH_KEYS_DEST"
        chmod 600 "$AUTH_KEYS_DEST"
    else
        log "⚠️ No authorized_keys found at $AUTH_KEYS_SRC"
    fi
    
    log "✅ SSH configuration complete."
    echo ""
}

setup_ssh_service() {
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           🚀 STEP 4: SSH SERVICE SETUP             "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    
    # Check if SSH server is already running
    if pgrep -f sshd > /dev/null; then
        log "⚠️ SSH server is already running"
        log "🛑 Stopping existing SSH server..."
        pkill -f sshd 2>/dev/null || true
        sleep 2
        
        # Verify it's stopped
        if pgrep -f sshd > /dev/null; then
            log "❌ Could not stop existing SSH server"
            log "💡 You may need to manually stop it: pkill -f sshd"
            return 1
        else
            log "✅ Existing SSH server stopped successfully"
        fi
    fi
    
    if [ -f "$SSH_SERVICE_SCRIPT" ]; then
        log "🔧 Installing SSH service..."
        bash "$SSH_SERVICE_SCRIPT" install | tee -a "$LOG"

        log "🚀 Starting SSH service..."
        SSH_OUTPUT=$(bash "$SSH_SERVICE_SCRIPT" start 2>&1)
        echo "$SSH_OUTPUT" | tee -a "$LOG"
        
        # Give the service a moment to start
        sleep 2
        
        # Check if SSH service started successfully
        if echo "$SSH_OUTPUT" | grep -q "SSH server started successfully"; then
            log "✅ SSH service setup complete."
            echo ""
            echo "$SSH_OUTPUT" | grep -E "(✓|→)" || true
        else
            log "❌ SSH service may not have started correctly"
            log "⚠️ Check the output above for any errors"
        fi
    else
        log "❌ SSH service script not found at $SSH_SERVICE_SCRIPT"
        log "⚠️ SSH service setup skipped - script not available"
    fi
    echo ""
}

# ==========================================
# MAIN EXECUTION
# ==========================================

main() {
    show_summary
    confirm_setup
    
    setup_ssh_agent
    clone_repository
    configure_ssh
    setup_ssh_service
    
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                ✅ SETUP COMPLETE                   "
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    log "✅ Git clone and SSH service setup complete."
    log "📁 Repository cloned to: $DEST"
    log "📍 Full log available at: $LOG"
    echo ""
    echo "🎉 All steps completed successfully!"
    echo "📍 View the full log at: $LOG"
    echo ""
    
    # Final completion message
    echo "Press Enter to exit..."
    read -r
    
    # Ensure script exits cleanly
    exit 0
}

# Run main function
main
