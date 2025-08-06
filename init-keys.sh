#!/data/data/com.termux/files/usr/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Colored output functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check and install dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    local missing_deps=()
    
    for dep in ssh-keygen termux-setup-storage; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    # ssh-keygen is part of openssh package
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        warning "openssh not found, installing..."
        if pkg install -y openssh; then
            success "openssh installed successfully"
        else
            error "Failed to install openssh"
            info "Please install manually: pkg install openssh"
            exit 1
        fi
    fi
    
    success "All dependencies are available"
}

# Create .ssh if missing
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Check dependencies first
check_dependencies

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