#!/data/data/com.termux/files/usr/bin/bash

# Termux Git Init - Quick Installer
# This script downloads and sets up termux-init-git

set -e

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

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    local missing_deps=()
    
    for dep in git curl; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        info "Installing missing packages..."
        pkg update && pkg install "${missing_deps[@]}"
    fi
    
    success "All dependencies are available"
}

# Download the repository
download_repo() {
    info "Downloading termux-init-git..."
    
    if [ -d "$INSTALL_DIR" ]; then
        warning "Directory $INSTALL_DIR already exists"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Updating existing installation..."
            cd "$INSTALL_DIR"
            git pull origin main
        else
            info "Using existing installation"
        fi
    else
        git clone "$REPO_URL" "$INSTALL_DIR"
        success "Repository downloaded to $INSTALL_DIR"
    fi
}

# Set up permissions
setup_permissions() {
    info "Setting up file permissions..."
    
    cd "$INSTALL_DIR"
    chmod +x init-keys.sh git-clone.sh
    
    if [ -d examples ]; then
        find examples -name "*.sh" -exec chmod +x {} \;
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
    echo "3. Add the deploy key to your GitHub repository"
    echo "4. Edit git-clone.sh with your repository URL"
    echo "5. ./git-clone.sh"
    echo ""
    info "📚 Documentation:"
    echo "- README.md - Complete setup guide"
    echo "- FAQ.md - Frequently asked questions"
    echo "- examples/ - Advanced usage examples"
    echo ""
    info "🔧 Troubleshooting:"
    echo "- ./examples/troubleshooting.sh - Diagnostic tool"
    echo "- View logs: cat $LOG_FILE"
    echo ""
    warning "Remember to review the scripts before running them!"
}

# Main installation process
main() {
    echo "🔐 Termux Git Init - Installer"
    echo "=============================="
    echo "Installing secure Git setup for Termux..."
    echo ""
    
    log "Installation started: $(date)"
    
    check_dependencies
    download_repo
    setup_permissions
    show_instructions
    
    log "Installation completed: $(date)"
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
    echo "1. Check and install required dependencies"
    echo "2. Download the termux-init-git repository"
    echo "3. Set up proper file permissions"
    echo "4. Show next steps for configuration"
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
        download_repo
        setup_permissions
        success "Update completed"
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
