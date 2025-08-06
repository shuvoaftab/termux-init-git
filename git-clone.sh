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
    until ssh -T -p 443 git@ssh.github.com 2>&1 | tee -a "$LOG" | grep -q "successfully authenticated"; do
        if (( attempt >= RETRIES )); then
            log "❌ Failed to authenticate with GitHub after $RETRIES attempts."
            exit 1
        fi
        log "⏳ GitHub auth not ready. Retrying ($attempt/$RETRIES)..."
        sleep 5
        ((attempt++))
    done
    log "✅ SSH auth with GitHub successful."
}

log "🔐 Verifying GitHub SSH access..."
retry_ssh_check

if [ -d "$DEST/.git" ]; then
    log "⚠️ Repo already exists at $DEST/.git, skipping clone."
else
    log "📦 Cloning repo to $DEST (with trace logging)..."
    GIT_TRACE=1 GIT_SSH_COMMAND="ssh -v" git clone "$REPO_SSH" "$DEST" 2>&1 | tee -a "$LOG"
fi

log "📁 Ensuring ~/.ssh exists..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

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
