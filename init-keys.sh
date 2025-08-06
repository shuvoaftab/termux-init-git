#!/data/data/com.termux/files/usr/bin/bash

# Create .ssh if missing
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate key if missing
KEY=~/.ssh/id_rsa_git
if [ ! -f "$KEY" ]; then
    echo "🔐 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$KEY" -N ""
else
    echo "✅ SSH key already exists at $KEY"
fi

# Ensure storage is set up
if [ ! -d ~/storage ]; then
    echo "📱 Setting up storage access..."
    termux-setup-storage
    sleep 2
fi

# Copy public key to shared storage
if [ -d ~/storage/shared ]; then
    cp "$KEY.pub" ~/storage/shared/id_rsa_git.pub
    echo "✅ Public key exported to Android storage."
else
    echo "⚠️ Could not access shared storage. Please run 'termux-setup-storage' manually."
fi

# Check if SSH config already has GitHub entry
if ! grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
    echo "⚙️ Configuring SSH for GitHub..."
    echo "
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile $KEY
" >> ~/.ssh/config
else
    echo "✅ SSH config already contains GitHub settings."
fi

chmod 600 ~/.ssh/config

# Download the git-clone script
echo "📥 Downloading git-clone script..."
if command -v curl >/dev/null 2>&1; then
    curl -o git-clone.sh https://raw.githubusercontent.com/shuvoaftab/termux-init-git/refs/heads/main/git-clone.sh
elif command -v wget >/dev/null 2>&1; then
    wget -O git-clone.sh https://raw.githubusercontent.com/shuvoaftab/termux-init-git/refs/heads/main/git-clone.sh
else
    echo "⚠️ Neither curl nor wget found. Please install one: pkg install curl"
    exit 1
fi

if [ -f git-clone.sh ]; then
    chmod +x git-clone.sh
    echo "✅ git-clone.sh downloaded and made executable."
else
    echo "❌ Failed to download git-clone.sh"
fi

echo ""
echo "👉 Please add this key to GitHub (Settings > Deploy Keys) for your private repo."
echo "🔁 After that, run: ./git-clone.sh"