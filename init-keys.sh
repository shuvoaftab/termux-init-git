#!/data/data/com.termux/files/usr/bin/bash

# Termux Git Init - SSH Key Generator
# This script sets up SSH keys for secure Git access

# Don't exit on first error - we want to handle errors gracefully
set -u

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# SSH key configuration
KEY_PATH=~/.ssh/id_rsa

# Colored output functions
info() {
    echo -e "${BLUE}⌘  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}🚸  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Show summary of what will be done
show_summary() {
    echo "� Termux Git Init - SSH Key Setup Summary"
    echo "=========================================="
    echo ""
    info "📝 This script will perform the following actions:"
    echo ""
    echo "1. 🔍 Check and install required dependencies:"
    echo "   • openssh - SSH client and key generation tools"
    echo "   • termux-setup-storage - Access to Android storage"
    echo ""
    echo "2. 📁 Create and secure SSH directory (~/.ssh)"
    echo ""
    echo "3. 🔑 Generate SSH key pair (if not exists):"
    echo "   • RSA 4096-bit key at ~/.ssh/id_rsa"
    echo "   • Public key at ~/.ssh/id_rsa.pub"
    echo ""
    echo "4. 📱 Setup Android storage access and export keys:"
    echo "   • Copy public key to shared storage"
    echo "   • Create timestamped backup"
    echo ""
    echo "5. ⚙️ Configure SSH for GitHub:"
    echo "   • Update ~/.ssh/config with GitHub settings"
    echo "   • Use port 443 for firewall compatibility"
    echo ""
    echo "6. 📥 Download git-clone.sh script for next step"
    echo ""
    warning "💡 Note: You'll need to add the public key to your GitHub repository"
    warning "📖 Storage permission will be requested if not already granted"
    echo ""
}

# Confirm setup
confirm_setup() {
    echo -n "Do you want to proceed with SSH key setup? (y/N): "
    
    # Handle piped input by reading from terminal directly
    if [ -t 0 ]; then
        read -n 1 -r REPLY
    else
        # When piped, read from terminal
        read -n 1 -r REPLY < /dev/tty
    fi
    echo ""
    
    case $REPLY in
        [Yy])
            success "Setup confirmed. Proceeding..."
            return 0
            ;;
        *)
            warning "Setup cancelled by user."
            exit 0
            ;;
    esac
}

# Check and install dependencies
check_dependencies() {
    echo ""
    echo "🔍 STEP 1: DEPENDENCY CHECK"
    echo "==========================="
    info "Checking required dependencies..."
    echo ""
    
    # Check for ssh-keygen (openssh package)
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        warning "openssh not found, installing..."
        if pkg install -y openssh; then
            success "✅ openssh installed successfully"
        else
            error "Failed to install openssh"
            info "Please install manually: pkg install openssh"
            exit 1
        fi
    else
        success "✅ ssh-keygen is available"
    fi
    
    # Check for termux-setup-storage
    if ! command -v termux-setup-storage >/dev/null 2>&1; then
        warning "termux-setup-storage not found"
        info "This should be included in Termux by default"
    else
        success "✅ termux-setup-storage is available"
    fi
    
    echo ""
    success "🎉 All dependencies are ready!"
    echo "=============================="
    echo ""
}

# Setup SSH directory and permissions
setup_ssh_directory() {
    echo ""
    echo "📁 STEP 2: SSH DIRECTORY SETUP"
    echo "==============================="
    info "Creating and securing SSH directory..."
    echo ""
    
    # Create .ssh directory if it doesn't exist
    if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh
        success "✅ Created ~/.ssh directory"
    else
        success "✅ ~/.ssh directory already exists"
    fi
    
    # Set proper permissions
    chmod 700 ~/.ssh
    success "✅ Set secure permissions (700) on ~/.ssh"
    
    echo ""
    success "🎉 SSH directory is ready!"
    echo "=========================="
    echo ""
}

# Generate SSH key pair
generate_ssh_key() {
    echo ""
    echo "🔑 STEP 3: SSH KEY GENERATION"
    echo "============================="
    info "Setting up SSH key pair..."
    echo ""
    
    if [ ! -f "$KEY_PATH" ]; then
        echo "🔨 Generating New SSH Key"
        echo "------------------------"
        info "Generating RSA 4096-bit SSH key..."
        if ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""; then
            success "✅ SSH key pair generated successfully"
            success "   - Private key: $KEY_PATH"
            success "   - Public key: $KEY_PATH.pub"
        else
            error "Failed to generate SSH key"
            exit 1
        fi
    else
        warning "SSH key already exists at $KEY_PATH"
        echo ""
        echo "📋 Choose Key Option:"
        echo "--------------------"
        echo "1) Regenerate new SSH key (overwrites existing)"
        echo "2) Keep existing key and continue"
        echo ""
        
        # Handle piped input by reading from terminal directly
        if [ -t 0 ]; then
            read -p "Enter your choice (1/2): " -n 1 -r
        else
            read -p "Enter your choice (1/2): " -n 1 -r < /dev/tty
        fi
        echo ""
        
        case $REPLY in
            1)
                echo ""
                echo "🔄 Regenerating SSH Key"
                echo "----------------------"
                warning "Removing existing SSH key..."
                rm -f "$KEY_PATH" "$KEY_PATH.pub"
                info "Generating new RSA 4096-bit SSH key..."
                if ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""; then
                    success "✅ New SSH key pair generated successfully"
                else
                    error "Failed to generate new SSH key"
                    exit 1
                fi
                ;;
            2)
                echo ""
                echo "📂 Using Existing Key"
                echo "--------------------"
                info "Using existing SSH key"
                ;;
            *)
                echo ""
                warning "Invalid choice. Using existing key."
                ;;
        esac
    fi
    
    # Verify key files exist and set permissions
    if [ -f "$KEY_PATH" ] && [ -f "$KEY_PATH.pub" ]; then
        chmod 600 "$KEY_PATH"
        chmod 644 "$KEY_PATH.pub"
        success "✅ Set secure permissions on key files"
    else
        error "SSH key files not found after generation"
        exit 1
    fi
    
    echo ""
    success "🎉 SSH key setup completed!"
    echo "=========================="
    echo ""
}

# Setup storage access and export keys
setup_storage_and_export() {
    echo ""
    echo "📱 STEP 4: ANDROID STORAGE SETUP"
    echo "================================="
    info "Setting up Android storage access and exporting keys..."
    echo ""
    
    # Setup storage access if needed
    if [ ! -d ~/storage ]; then
        echo "🔐 Requesting Storage Permission"
        echo "-------------------------------"
        info "Setting up storage access..."
        warning "🚸 Please grant storage permission when prompted"
        termux-setup-storage
        sleep 3
        
        if [ -d ~/storage ]; then
            success "✅ Storage access granted"
        else
            warning "🚸 Storage access may not be fully ready"
        fi
    else
        success "✅ Storage access already available"
    fi
    
    echo ""
    echo "📤 Exporting Public Key"
    echo "----------------------"
    # Export public key to shared storage
    if [ -d ~/storage/shared ]; then
        # Generate timestamp for unique filename
        TIMESTAMP=$(date '+%Y-%m-%d_%H%M')
        EXPORT_FILENAME="id_rsa_${TIMESTAMP}.pub"
        
        # Copy with timestamp
        if cp "$KEY_PATH.pub" ~/storage/shared/"$EXPORT_FILENAME"; then
            success "✅ Public key exported as: $EXPORT_FILENAME"
        else
            warning "🚸 Failed to create timestamped copy"
        fi
        
        # Create latest version
        if cp "$KEY_PATH.pub" ~/storage/shared/id_rsa.pub; then
            success "✅ Also saved as: id_rsa.pub (latest)"
        else
            warning "🚸 Failed to create latest copy"
        fi
        
        echo ""
        info "📍 Public key locations in Android storage:"
        echo "   • ~/storage/shared/$EXPORT_FILENAME"
        echo "   • ~/storage/shared/id_rsa.pub"
        
    else
        warning "🚸 Could not access shared storage"
        info "Please run 'termux-setup-storage' manually if needed"
    fi
    
    echo ""
    success "🎉 Storage setup completed!"
    echo "=========================="
    echo ""
}

# Configure SSH for GitHub
configure_ssh_github() {
    echo ""
    echo "⚙️  STEP 5: GITHUB SSH CONFIGURATION"
    echo "==================================="
    info "Configuring SSH settings for GitHub..."
    echo ""
    
    # Check if SSH config already has GitHub entry
    if ! grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
        echo "📝 Creating SSH Config"
        echo "---------------------"
        info "Adding GitHub configuration to SSH config..."
        
        # Create SSH config with GitHub settings
        cat >> ~/.ssh/config << EOF

Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile $KEY_PATH
EOF
        
        success "✅ SSH config updated for GitHub"
        success "   - Using port 443 for firewall compatibility"
        success "   - Using SSH hostname: ssh.github.com"
        
    else
        success "✅ SSH config already contains GitHub settings"
    fi
    
    # Set proper permissions on config file
    if [ -f ~/.ssh/config ]; then
        chmod 600 ~/.ssh/config
        success "✅ Set secure permissions on SSH config"
    fi
    
    echo ""
    success "🎉 GitHub SSH configuration completed!"
    echo "====================================="
    echo ""
}

# Download git-clone script
download_git_clone_script() {
    echo ""
    echo "📥 STEP 6: DOWNLOADING GIT-CLONE SCRIPT"
    echo "========================================"
    info "Downloading git-clone script for repository setup..."
    echo ""
    
    local script_url="https://raw.githubusercontent.com/shuvoaftab/termux-init-git/refs/heads/main/git-clone.sh"
    local download_success=false
    
    # Try curl first
    if command -v curl >/dev/null 2>&1; then
        echo "📡 Downloading with curl"
        echo "----------------------"
        if curl -o git-clone.sh "$script_url"; then
            success "✅ Downloaded git-clone.sh using curl"
            download_success=true
        else
            warning "🚸 Failed to download with curl"
        fi
    fi
    
    # Try wget if curl failed
    if [ "$download_success" = false ] && command -v wget >/dev/null 2>&1; then
        echo "📡 Downloading with wget"
        echo "----------------------"
        if wget -O git-clone.sh "$script_url"; then
            success "✅ Downloaded git-clone.sh using wget"
            download_success=true
        else
            warning "🚸 Failed to download with wget"
        fi
    fi
    
    # Check if download was successful
    if [ "$download_success" = false ]; then
        error "Neither curl nor wget succeeded"
        info "Please install curl or wget: pkg install curl"
        exit 1
    fi
    
    # Make script executable
    if [ -f git-clone.sh ]; then
        chmod +x git-clone.sh
        success "✅ git-clone.sh made executable"
    else
        error "git-clone.sh file not found after download"
        exit 1
    fi
    
    echo ""
    success "🎉 git-clone.sh script ready!"
    echo "============================"
    echo ""
}

# Show final instructions
show_final_instructions() {
    echo ""
    echo "📋 STEP 7: SETUP COMPLETE - NEXT STEPS"
    echo "======================================"
    success "SSH key setup completed successfully!"
    echo ""
    
    info "📋 Next Steps to Connect to GitHub:"
    echo "-----------------------------------"
    echo "1. 📱 Open your Android file manager"
    echo "2. 📂 Navigate to the shared storage folder"
    echo "3. 📄 Find and open: id_rsa.pub"
    echo "4. 📋 Copy the entire content of the public key"
    echo "5. 🌐 Go to your GitHub repository settings"
    echo "6. 🔑 Navigate to: Settings > Deploy Keys"
    echo "7. ➕ Click 'Add deploy key'"
    echo "8. 📝 Paste the public key content"
    echo "9. ✅ Save the deploy key"
    echo "10. 🚀 Run: ./git-clone.sh"
    echo ""
    
    info "📍 Public Key Locations:"
    echo "------------------------"
    TIMESTAMP=$(date '+%Y-%m-%d_%H%M')
    echo "   • Timestamped: ~/storage/shared/id_rsa_${TIMESTAMP}.pub"
    echo "   • Latest: ~/storage/shared/id_rsa.pub"
    echo ""
    
    info "🔧 Available Commands:"
    echo "---------------------"
    echo "   • View public key: cat ~/.ssh/id_rsa.pub"
    echo "   • Test SSH connection: ssh -T git@github.com"
    echo "   • Start cloning: ./git-clone.sh"
    echo ""
    
    warning "📖 Important Notes:"
    echo "   • The private key stays secure in ~/.ssh/"
    echo "   • Only share the PUBLIC key (.pub file)"
    echo "   • Test the SSH connection before cloning"
    echo ""
}

# Main setup process
main() {
    echo "🔐 Termux Git Init - SSH Key Setup"
    echo "=================================="
    echo "Setting up SSH keys for secure Git access..."
    echo ""
    
    # Show summary of what will be done
    show_summary
    
    # Ask for user confirmation
    confirm_setup
    
    # Execute setup steps
    check_dependencies
    setup_ssh_directory
    generate_ssh_key
    setup_storage_and_export
    configure_ssh_github
    download_git_clone_script
    show_final_instructions
    
    echo ""
    echo "🎉 SSH KEY SETUP COMPLETED SUCCESSFULLY!"
    echo "========================================"
    echo ""
    success "🚀 Ready for next step! Run this command:"
    echo ""
    info "./git-clone.sh"
    echo ""
    warning "📖 Don't forget to add your public key to GitHub first!"
}

# Show help
show_help() {
    echo "Termux Git Init - SSH Key Setup"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "This script will:"
    echo "1. Check and install required dependencies (openssh)"
    echo "2. Create secure SSH directory (~/.ssh)"
    echo "3. Generate RSA 4096-bit SSH key pair"
    echo "4. Setup Android storage access and export public key"
    echo "5. Configure SSH settings for GitHub"
    echo "6. Download git-clone.sh script for repository setup"
    echo "7. Show instructions for adding public key to GitHub"
    echo ""
    echo "The generated public key will be available in:"
    echo "• Android shared storage for easy access"
    echo "• ~/.ssh/id_rsa.pub for command-line use"
    echo ""
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    "")
        main
        ;;
    *)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac