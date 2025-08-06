#!/data/data/com.termux/files/usr/bin/bash

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

retry_ssh_check() {
    local attempt=1
    log "🔍 Testing SSH connection to GitHub via port 443..."
    
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

log "🔐 Verifying GitHub SSH access..."

# Ensure SSH agent is running and keys are loaded
if [ -z "$SSH_AUTH_SOCK" ]; then
    log "🚀 Starting SSH agent..."
    eval "$(ssh-agent -s)" | tee -a "$LOG"
fi

# Add any SSH keys in ~/.ssh to the agent
for key in ~/.ssh/id_*; do
    if [ -f "$key" ] && [ ! "${key##*.}" = "pub" ]; then
        log "🔑 Adding key to SSH agent: $key"
        ssh-add "$key" 2>&1 | tee -a "$LOG"
    fi
done

retry_ssh_check

if [ -d "$DEST/.git" ]; then
    log "⚠️ Repo already exists at $DEST/.git, skipping clone."
else
    log "📦 Cloning repo contents to $DEST (with trace logging)..."
    # Create a temporary directory for cloning
    TEMP_CLONE="/tmp/termux-namp-$$"
    GIT_TRACE=1 GIT_SSH_COMMAND="ssh -v" git clone "$REPO_SSH" "$TEMP_CLONE" 2>&1 | tee -a "$LOG"
    
    if [ $? -eq 0 ]; then
        log "📁 Moving repository contents to $DEST..."
        # Move all contents including .git to HOME
        mv "$TEMP_CLONE"/* "$TEMP_CLONE"/.[^.]* "$DEST/" 2>/dev/null
        rmdir "$TEMP_CLONE"
        log "✅ Repository cloned successfully to $DEST"
    else
        log "❌ Clone failed"
        rm -rf "$TEMP_CLONE"
        exit 1
    fi
fi

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

if [ -f "$SSH_SERVICE_SCRIPT" ]; then
    log "🔧 Installing SSH service..."
    bash "$SSH_SERVICE_SCRIPT" install | tee -a "$LOG"

    log "🚀 Starting SSH service..."
    bash "$SSH_SERVICE_SCRIPT" start | tee -a "$LOG"
else
    log "❌ SSH service script not found at $SSH_SERVICE_SCRIPT"
    exit 1
fi

log "✅ Setup complete. View the full log at $LOG"
