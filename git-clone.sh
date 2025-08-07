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
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 TERMUX-INIT-GIT: STEP 3/3 - GIT CLONE                 ║"
    echo "║                         Repository Clone & SSH Service Setup                 ║"
    echo "╠═══════════════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                               ║"
    echo "║ 📋 SUMMARY OF WHAT WILL BE DONE:                                             ║"
    echo "║                                                                               ║"
    echo "║ 🔐 1. SSH Connection Verification                                            ║"
    echo "║     • Verify GitHub SSH access via port 443                                  ║"
    echo "║     • Start SSH agent and load keys                                          ║"
    echo "║     • Test authentication with GitHub                                        ║"
    echo "║                                                                               ║"
    echo "║ 📦 2. Repository Cloning                                                     ║"
    echo "║     • Clone repository: android-research/termux-namp                         ║"
    echo "║     • Setup repository contents in home directory                            ║"
    echo "║                                                                               ║"
    echo "║ 🔧 3. SSH Configuration                                                      ║"
    echo "║     • Configure ~/.ssh directory and permissions                             ║"
    echo "║     • Add GitHub to known_hosts                                              ║"
    echo "║     • Setup authorized_keys from repository                                  ║"
    echo "║                                                                               ║"
    echo "║ 🚀 4. SSH Service Setup                                                      ║"
    echo "║     • Install SSH service daemon                                             ║"
    echo "║     • Start SSH service for remote access                                    ║"
    echo "║                                                                               ║"
    echo "║ ⚠️  PREREQUISITES (from Step 2/3):                                           ║"
    echo "║     • SSH public key must be added to GitHub repository as deploy key       ║"
    echo "║     • SSH key should be generated and configured from previous step         ║"
    echo "║                                                                               ║"
    echo "║ 📍 LOG FILE: ~/git-ssh-setup.log                                            ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

confirm_setup() {
    echo "⚠️  IMPORTANT: Make sure you have completed Step 2/3 and added your SSH public key to GitHub!"
    echo ""
    echo "🔗 Add your SSH key as a deploy key at:"
    echo "   https://github.com/android-research/termux-namp/settings/keys"
    echo ""
    read -p "Do you want to proceed with the repository clone and SSH service setup? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled by user."
        exit 0
    fi
    echo "✅ Proceeding with git clone and SSH service setup..."
    echo ""
}

# ==========================================
# MAIN SETUP FUNCTIONS
# ==========================================

retry_ssh_check() {
    local attempt=1
    log "🔍 Testing SSH connection to GitHub via port 443..."
    
    # Use SSH config settings (no need to specify key file)
    until ssh -T -p 443 git@ssh.github.com 2>&1 | tee -a "$LOG" | grep -E "(successfully authenticated|You've successfully authenticated)" > /dev/null; do
        if (( attempt >= RETRIES )); then
            log "❌ Failed to authenticate with GitHub after $RETRIES attempts."
            log "💡 Make sure your SSH key is added as a deploy key to the repository."
            log "💡 You can test manually with: ssh -T -p 443 git@ssh.github.com"
            
            # Show last SSH attempt for debugging
            log "🔍 Last SSH attempt output:"
            ssh -T -p 443 git@ssh.github.com 2>&1 | tail -5 | tee -a "$LOG"
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
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🔐 STEP 1: SSH CONNECTION VERIFICATION               ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    log "🔐 Verifying GitHub SSH access..."

    # Ensure SSH agent is running and keys are loaded
    if [ -z "$SSH_AUTH_SOCK" ]; then
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
            if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
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
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                            📦 STEP 2: REPOSITORY CLONING                      ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ -d "$DEST/.git" ]; then
        log "⚠️ Repo already exists at $DEST/.git, skipping clone."
    else
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
    fi
    log "✅ Repository cloning complete."
    echo ""
}

configure_ssh() {
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           🔧 STEP 3: SSH CONFIGURATION                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
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
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           🚀 STEP 4: SSH SERVICE SETUP                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ -f "$SSH_SERVICE_SCRIPT" ]; then
        log "🔧 Installing SSH service..."
        bash "$SSH_SERVICE_SCRIPT" install | tee -a "$LOG"

        log "🚀 Starting SSH service..."
        bash "$SSH_SERVICE_SCRIPT" start | tee -a "$LOG"
        
        # Give the service a moment to start
        sleep 2
        
        log "✅ SSH service setup complete."
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
    
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              ✅ SETUP COMPLETE                                ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    log "✅ Git clone and SSH service setup complete."
    log "📁 Repository cloned to: $DEST"
    log "📍 Full log available at: $LOG"
    echo ""
    echo "🎉 All steps completed successfully!"
    echo "📍 View the full log at: $LOG"
    echo ""
    
    # Ensure script exits cleanly
    exit 0
}

# Run main function
main
