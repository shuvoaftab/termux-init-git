#!/data/data/com.termux/files/usr/bin/bash

# Termux Git Init - Quick Installer
# This script downloads and sets up termux-init-git

# Don't exit on first error - we want to handle errors gracefully
set -u  # Exit on undefined variables instead

REPO_URL="https://github.com/shuvoaftab/termux-init-git"
INSTALL_DIR="$HOME/termux-init-git"
LOG_FILE="$HOME/termux-init-git-install.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Colored output functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

# Show summary of what will be done
show_summary() {
    echo "🔐 Termux Git Init - Installation Summary"
    echo "========================================"
    echo ""
    info "📝 This script will perform the following actions:"
    echo ""
    echo "1. 📦 Install required packages:"
    echo "   • wget - Download utility"
    echo "   • curl - HTTP client"
    echo "   • vim - Text editor"
    echo "   • busybox - Unix utilities"
    echo "   • git - Version control system"
    echo "   • openssh - SSH client/server"
    echo ""
    echo "2. 🔍 Check and verify all dependencies are working"
    echo ""
    echo "3. 📥 Download termux-init-git repository from:"
    echo "   $REPO_URL"
    echo "   to: $INSTALL_DIR"
    echo ""
    echo "4. 🔧 Set up proper file permissions for scripts"
    echo ""
    echo "5. 📋 Display setup instructions and next steps"
    echo ""
    warning "💡 Note: Package installation requires internet connection"
    warning "📖 Please review the scripts before running them after installation"
    echo ""
}

# Confirm installation
confirm_installation() {
    echo -n "Do you want to proceed with the installation? (y/N): "
    
    # Handle piped input by reading from terminal directly
    if [ -t 0 ]; then
        read -n 1 -r REPLY
    else
        # When piped (like from curl), read from terminal
        read -n 1 -r REPLY < /dev/tty
    fi
    echo ""
    
    case $REPLY in
        [Yy])
            success "Installation confirmed. Proceeding..."
            return 0
            ;;
        *)
            warning "Installation cancelled by user."
            exit 0
            ;;
    esac
}

# Install essential packages first
install_essential_packages() {
    info "Installing essential packages..."
    
    # Update package list first
    info "Updating package list..."
    if pkg update -y; then
        success "Package list updated"
    else
        warning "Package update failed, continuing anyway..."
    fi
    
    # Install all required packages in one go
    local packages="wget curl vim busybox git openssh"
    info "Installing packages: $packages"
    
    if pkg install -y $packages; then
        success "All essential packages installed successfully"
    else
        error "Failed to install some packages"
        info "Attempting individual package installation..."
        
        # Try installing packages individually if bulk install fails
        for pkg_name in $packages; do
            info "Installing $pkg_name..."
            if pkg install -y "$pkg_name"; then
                success "$pkg_name installed"
            else
                warning "Failed to install $pkg_name - may already be installed or unavailable"
            fi
        done
    fi
    
    # Verify critical packages
    local critical_missing=()
    for dep in git curl ssh-keygen; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            critical_missing+=("$dep")
        fi
    done
    
    if [ ${#critical_missing[@]} -gt 0 ]; then
        error "Critical packages still missing: ${critical_missing[*]}"
        info "Please install manually and run this script again"
        exit 1
    fi
    
    success "Essential packages installation completed"
}

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    local missing_deps=()
    
    for dep in git curl openssh; do
        if [ "$dep" = "openssh" ]; then
            # Check for ssh-keygen instead of openssh command
            if ! command -v ssh-keygen >/dev/null 2>&1; then
                missing_deps+=("openssh")
            fi
        else
            if ! command -v "$dep" >/dev/null 2>&1; then
                missing_deps+=("$dep")
            fi
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warning "Missing dependencies: ${missing_deps[*]}"
        info "Installing missing packages..."
        
        # Update package list
        if ! pkg update -y; then
            warning "Package update failed, continuing anyway..."
        fi
        
        # Install missing packages with auto-confirmation
        for dep in "${missing_deps[@]}"; do
            info "Installing $dep..."
            if pkg install -y "$dep"; then
                success "$dep installed successfully"
            else
                error "Failed to install $dep"
                info "Please install manually: pkg install $dep"
                exit 1
            fi
        done
    fi
    
    success "All dependencies are available"
}

# Download the repository
download_repo() {
    info "Downloading termux-init-git..."
    
    if [ -d "$INSTALL_DIR" ]; then
        warning "Directory $INSTALL_DIR already exists"
        echo ""
        echo "Choose an option:"
        echo "1) Remove and download fresh copy (recommended)"
        echo "2) Update existing installation (git pull)"
        echo "3) Keep existing and continue"
        echo ""
        
        # Handle piped input by reading from terminal directly
        if [ -t 0 ]; then
            read -p "Enter your choice (1/2/3): " -n 1 -r
        else
            # When piped (like from curl), read from terminal
            read -p "Enter your choice (1/2/3): " -n 1 -r < /dev/tty
        fi
        echo ""
        
        case $REPLY in
            1)
                warning "Removing existing directory..."
                if rm -rf "$INSTALL_DIR"; then
                    success "Existing directory removed"
                else
                    error "Failed to remove existing directory"
                    exit 1
                fi
                info "Downloading fresh copy from $REPO_URL..."
                if git clone "$REPO_URL" "$INSTALL_DIR"; then
                    success "Fresh repository downloaded to $INSTALL_DIR"
                else
                    error "Failed to clone repository"
                    info "Please check your internet connection and try again"
                    exit 1
                fi
                ;;
            2)
                info "Updating existing installation..."
                if cd "$INSTALL_DIR"; then
                    if git pull origin main; then
                        success "Repository updated successfully"
                    else
                        error "Failed to update repository"
                        info "You may need to remove $INSTALL_DIR and run the installer again"
                        exit 1
                    fi
                else
                    error "Could not enter directory $INSTALL_DIR"
                    exit 1
                fi
                ;;
            3)
                info "Using existing installation"
                ;;
            *)
                warning "Invalid choice. Using existing installation"
                ;;
        esac
    else
        info "Cloning repository from $REPO_URL..."
        if git clone "$REPO_URL" "$INSTALL_DIR"; then
            success "Repository downloaded to $INSTALL_DIR"
        else
            error "Failed to clone repository"
            info "Please check your internet connection and try again"
            exit 1
        fi
    fi
}

# Set up permissions
setup_permissions() {
    info "Setting up file permissions..."
    
    if ! cd "$INSTALL_DIR"; then
        error "Failed to enter directory $INSTALL_DIR"
        exit 1
    fi
    
    # Make main scripts executable
    for script in init-keys.sh git-clone.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            info "Made $script executable"
        else
            warning "$script not found - may need manual setup"
        fi
    done
    
    # Make example scripts executable
    if [ -d examples ]; then
        find examples -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        info "Made example scripts executable"
    fi
    
    success "Permissions set correctly"
}

# Show next steps
show_instructions() {
    success "Installation completed successfully!"
    echo ""
    
    info "📋 Next Steps:"
    echo "1. cd $INSTALL_DIR"
    echo "2. ./init-keys.sh"
    echo "3. Add the deploy key to your GitHub repository (Settings > Deploy Keys)"
    echo "4. Edit git-clone.sh with your repository URL"
    echo "5. ./git-clone.sh"
    echo ""
    info "📚 Available Documentation:"
    echo "- README.md - Complete setup guide"
    echo "- FAQ.md - Frequently asked questions"  
    echo "- CONTRIBUTING.md - Contribution guidelines"
    echo "- examples/ - Advanced usage examples"
    echo ""
    info "🔧 Quick Commands (after cd $INSTALL_DIR):"
    echo "- View README: cat README.md"
    echo "- Start setup: ./init-keys.sh"
    echo "- Get help: ./init-keys.sh --help"
    echo "- Troubleshoot: ./examples/troubleshooting.sh"
    echo "- View logs: cat $LOG_FILE"
    echo ""
    warning "📖 Please review the scripts before running them!"
    echo ""
    success "🚀 Quick start:"
    info "cd $INSTALL_DIR && ./init-keys.sh"
}

# Main installation process
main() {
    echo "🔐 Termux Git Init - Installer"
    echo "=============================="
    echo "Installing secure Git setup for Termux..."
    echo ""
    
    # Show summary of what will be done
    show_summary
    
    # Ask for user confirmation
    confirm_installation
    
    # Create log file directory if needed
    local log_dir=$(dirname "$LOG_FILE")
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi
    
    # Initialize log file
    if ! touch "$LOG_FILE" 2>/dev/null; then
        warning "Cannot create log file at $LOG_FILE"
        LOG_FILE="/tmp/termux-init-git-install.log"
        info "Using temporary log file: $LOG_FILE"
    fi
    
    log "Installation started: $(date)"
    log "HOME directory: $HOME"
    log "Install directory: $INSTALL_DIR"
    log "Log file: $LOG_FILE"
    
    info "Checking environment..."
    info "Current shell: $0"
    info "Working directory: $(pwd)"
    
    # Install essential packages first
    install_essential_packages
    
    # Then check all dependencies
    check_dependencies
    download_repo
    setup_permissions
    show_instructions
    
    log "Installation completed: $(date)"
    
    # Show simple next steps
    if [ -d "$INSTALL_DIR" ]; then
        echo ""
        success "🎉 Installation complete!"
        echo ""
        success "🚀 To start setup, copy and run this command:"
        echo ""
        info "cd $INSTALL_DIR && ./init-keys.sh"
        echo ""
        warning "📖 Please review the scripts before running them!"
    fi
}

# Show help
show_help() {
    echo "Termux Git Init - Quick Installer"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo "  --update      Update existing installation"
    echo "  --uninstall   Remove installation"
    echo ""
    echo "This script will:"
    echo "1. Show a summary of actions to be performed"
    echo "2. Ask for user confirmation to proceed"
    echo "3. Install essential packages (wget, curl, vim, busybox, git, openssh)"
    echo "4. Check and verify all dependencies are working"
    echo "5. Download the termux-init-git repository"
    echo "6. Set up proper file permissions"
    echo "7. Show next steps for configuration"
    echo ""
    echo "For more information, visit:"
    echo "$REPO_URL"
}

# Uninstall function
uninstall() {
    warning "Uninstalling termux-init-git..."
    
    if [ -d "$INSTALL_DIR" ]; then
        read -p "Are you sure you want to remove $INSTALL_DIR? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            success "Uninstallation completed"
        else
            info "Uninstallation cancelled"
        fi
    else
        warning "Installation directory not found"
    fi
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --update)
        info "Updating installation..."
        if [ -d "$INSTALL_DIR" ]; then
            cd "$INSTALL_DIR"
            if git pull origin main; then
                success "Repository updated successfully"
                setup_permissions
                success "Update completed"
                info "Current directory: $(pwd)"
                info "Run './init-keys.sh' to start setup"
            else
                error "Failed to update repository"
                info "Try removing and reinstalling: rm -rf $INSTALL_DIR"
                exit 1
            fi
        else
            warning "Installation directory not found. Downloading fresh copy..."
            download_repo
            setup_permissions
            success "Fresh installation completed"
        fi
        exit 0
        ;;
    --uninstall)
        uninstall
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
