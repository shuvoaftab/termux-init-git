#!/data/data/com.termux/files/usr/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Coecho ""
info "📋 Next Steps:"
echo "1. Add the public key to GitHub (Settings > Deploy Keys) for your private repo"
echo "2. Run: ./git-clone.sh"
echo ""
warning "Public key locations in storage:"
info "- Timestamped: ~/storage/shared/id_rsa_$(date '+%Y-%m-%d_%H%M').pub"
info "- Latest: ~/storage/shared/id_rsa.pub" Colored output functions
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
KEY=~/.ssh/id_rsa
if [ ! -f "$KEY" ]; then
    info "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$KEY" -N ""
    success "SSH key generated at $KEY"
else
    warning "SSH key already exists at $KEY"
    echo ""
    echo "Choose an option:"
    echo "1) Regenerate new SSH key (overwrites existing)"
    echo "2) Keep existing key and continue"
    echo ""
    read -p "Enter your choice (1/2): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            warning "Regenerating SSH key..."
            rm -f "$KEY" "$KEY.pub"
            ssh-keygen -t rsa -b 4096 -f "$KEY" -N ""
            success "New SSH key generated at $KEY"
            ;;
        2)
            info "Using existing SSH key"
            ;;
        *)
            error "Invalid choice. Using existing key."
            ;;
    esac
fi

# Ensure storage is set up
if [ ! -d ~/storage ]; then
    info "Setting up storage access..."
    termux-setup-storage
    sleep 2
fi

# Copy public key to shared storage with timestamp
if [ -d ~/storage/shared ]; then
    # Generate timestamp in Y-m-d_HHMM format (no colons for filename compatibility)
    TIMESTAMP=$(date '+%Y-%m-%d_%H%M')
    EXPORT_FILENAME="id_rsa_${TIMESTAMP}.pub"
    
    cp "$KEY.pub" ~/storage/shared/"$EXPORT_FILENAME"
    success "Public key exported to Android storage as: $EXPORT_FILENAME"
    
    # Also create a copy without timestamp for convenience
    cp "$KEY.pub" ~/storage/shared/id_rsa.pub
    info "Also saved as: id_rsa.pub (latest)"
else
    warning "Could not access shared storage. Please run 'termux-setup-storage' manually."
fi

# Check if SSH config already has GitHub entry
if ! grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
    info "Configuring SSH for GitHub..."
    echo "
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile $KEY
" >> ~/.ssh/config
    success "SSH config updated for GitHub"
else
    success "SSH config already contains GitHub settings"
fi

chmod 600 ~/.ssh/config

# Download the git-clone script
info "Downloading git-clone script..."
if command -v curl >/dev/null 2>&1; then
    if curl -o git-clone.sh https://raw.githubusercontent.com/shuvoaftab/termux-init-git/refs/heads/main/git-clone.sh; then
        success "Downloaded git-clone.sh using curl"
    else
        error "Failed to download with curl"
    fi
elif command -v wget >/dev/null 2>&1; then
    if wget -O git-clone.sh https://raw.githubusercontent.com/shuvoaftab/termux-init-git/refs/heads/main/git-clone.sh; then
        success "Downloaded git-clone.sh using wget"
    else
        error "Failed to download with wget"
    fi
else
    error "Neither curl nor wget found. Please install one: pkg install curl"
    exit 1
fi

if [ -f git-clone.sh ]; then
    chmod +x git-clone.sh
    success "git-clone.sh downloaded and made executable"
else
    error "Failed to download git-clone.sh"
fi

echo ""
info "📋 Next Steps:"
echo "1. Add the public key to GitHub (Settings > Deploy Keys) for your private repo"
echo "2. Run: ./git-clone.sh"
echo ""
warning "Public key location in storage: ~/storage/shared/id_rsa_$(date '+%Y-%m-%d_%H%M').pub"