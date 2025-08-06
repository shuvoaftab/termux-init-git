#!/data/data/com.termux/files/usr/bin/bash

# Troubleshooting Script for termux-init-git
# This script provides common debugging commands and solutions

echo "🔍 Termux Git SSH Troubleshooting Tool"
echo "======================================="

# Function to run a command and show its output
run_check() {
    local description="$1"
    local command="$2"
    
    echo ""
    echo "🔎 $description"
    echo "Running: $command"
    echo "---"
    if eval "$command"; then
        echo "✅ Success"
    else
        echo "❌ Failed (exit code: $?)"
    fi
    echo ""
}

# Function to check file permissions
check_permissions() {
    echo "🔐 Checking SSH file permissions..."
    
    if [ -d ~/.ssh ]; then
        ls -la ~/.ssh/ | while read line; do
            echo "  $line"
        done
        
        # Check for common permission issues
        ssh_dir_perms=$(stat -c "%a" ~/.ssh 2>/dev/null || stat -f "%A" ~/.ssh 2>/dev/null)
        if [ "$ssh_dir_perms" != "700" ]; then
            echo "⚠️  SSH directory permissions should be 700, found: $ssh_dir_perms"
            echo "   Fix with: chmod 700 ~/.ssh"
        fi
        
        if [ -f ~/.ssh/id_rsa_git ]; then
            key_perms=$(stat -c "%a" ~/.ssh/id_rsa_git 2>/dev/null || stat -f "%A" ~/.ssh/id_rsa_git 2>/dev/null)
            if [ "$key_perms" != "600" ]; then
                echo "⚠️  Private key permissions should be 600, found: $key_perms"
                echo "   Fix with: chmod 600 ~/.ssh/id_rsa_git"
            fi
        fi
    else
        echo "❌ ~/.ssh directory does not exist"
    fi
}

# Function to test GitHub connectivity
test_github_connection() {
    echo "🌐 Testing GitHub SSH connectivity..."
    
    # Test basic connectivity
    if ping -c 1 github.com >/dev/null 2>&1; then
        echo "✅ Can reach github.com"
    else
        echo "❌ Cannot reach github.com - check internet connection"
    fi
    
    # Test SSH port 443
    if nc -z ssh.github.com 443 2>/dev/null; then
        echo "✅ Port 443 to ssh.github.com is open"
    else
        echo "❌ Port 443 to ssh.github.com is blocked"
    fi
    
    # Test SSH authentication
    echo "🔑 Testing SSH authentication..."
    ssh -T -o ConnectTimeout=10 git@github.com 2>&1 | head -3
}

# Function to check SSH configuration
check_ssh_config() {
    echo "⚙️ Checking SSH configuration..."
    
    if [ -f ~/.ssh/config ]; then
        echo "SSH config file exists:"
        echo "---"
        cat ~/.ssh/config
        echo "---"
        
        # Check for GitHub configuration
        if grep -q "Host github.com" ~/.ssh/config; then
            echo "✅ GitHub configuration found in SSH config"
        else
            echo "⚠️ No GitHub configuration found in SSH config"
        fi
    else
        echo "❌ No SSH config file found at ~/.ssh/config"
    fi
}

# Function to check environment
check_environment() {
    echo "🏗️ Checking Termux environment..."
    
    echo "Termux version:"
    termux-info | grep -E "(Termux version|Android version|Device)" || echo "termux-info not available"
    
    echo ""
    echo "Required packages:"
    for pkg in git openssh curl; do
        if command -v "$pkg" >/dev/null 2>&1; then
            echo "  ✅ $pkg: $(command -v "$pkg")"
        else
            echo "  ❌ $pkg: not installed"
            echo "     Install with: pkg install $pkg"
        fi
    done
    
    echo ""
    echo "Storage access:"
    if [ -d ~/storage ]; then
        echo "  ✅ Storage access granted"
    else
        echo "  ❌ Storage access not granted"
        echo "     Run: termux-setup-storage"
    fi
}

# Function to check logs
check_logs() {
    echo "📝 Checking setup logs..."
    
    if [ -f ~/git-ssh-setup.log ]; then
        echo "Setup log found. Last 10 lines:"
        echo "---"
        tail -10 ~/git-ssh-setup.log
        echo "---"
        
        # Check for common errors in logs
        if grep -q "Permission denied" ~/git-ssh-setup.log; then
            echo "⚠️ Permission denied errors found in log"
        fi
        
        if grep -q "Connection refused" ~/git-ssh-setup.log; then
            echo "⚠️ Connection refused errors found in log"
        fi
        
        if grep -q "successfully authenticated" ~/git-ssh-setup.log; then
            echo "✅ Successful authentication found in log"
        fi
    else
        echo "❌ No setup log found at ~/git-ssh-setup.log"
    fi
}

# Function to provide common solutions
show_solutions() {
    echo "🛠️ Common Solutions"
    echo "==================="
    
    echo ""
    echo "1. Fix SSH permissions:"
    echo "   chmod 700 ~/.ssh"
    echo "   chmod 600 ~/.ssh/id_rsa_git"
    echo "   chmod 644 ~/.ssh/id_rsa_git.pub"
    echo "   chmod 644 ~/.ssh/config"
    
    echo ""
    echo "2. Re-generate SSH key:"
    echo "   rm -f ~/.ssh/id_rsa_git*"
    echo "   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_git -N ''"
    
    echo ""
    echo "3. Test SSH connection manually:"
    echo "   ssh -vT git@github.com"
    echo "   ssh -i ~/.ssh/id_rsa_git -T git@github.com"
    
    echo ""
    echo "4. Reset SSH configuration:"
    echo "   mv ~/.ssh/config ~/.ssh/config.backup"
    echo "   # Then re-run init-keys.sh"
    
    echo ""
    echo "5. Check deploy key in GitHub:"
    echo "   - Go to repository Settings > Deploy keys"
    echo "   - Verify the key is added and active"
    echo "   - Ensure 'Allow write access' is checked if needed"
    
    echo ""
    echo "6. Clear SSH known hosts (if connection issues):"
    echo "   ssh-keygen -R github.com"
    echo "   ssh-keygen -R ssh.github.com"
}

# Function to run all checks
run_all_checks() {
    check_environment
    echo ""
    check_permissions
    echo ""
    check_ssh_config
    echo ""
    test_github_connection
    echo ""
    check_logs
    echo ""
    show_solutions
}

# Function to show menu
show_menu() {
    echo ""
    echo "Choose an option:"
    echo "1. Run all checks"
    echo "2. Check environment only"
    echo "3. Check SSH permissions"
    echo "4. Test GitHub connection"
    echo "5. Check SSH configuration"
    echo "6. Check setup logs"
    echo "7. Show common solutions"
    echo "8. Exit"
    echo ""
    read -p "Enter choice (1-8): " choice
    
    case $choice in
        1) run_all_checks ;;
        2) check_environment ;;
        3) check_permissions ;;
        4) test_github_connection ;;
        5) check_ssh_config ;;
        6) check_logs ;;
        7) show_solutions ;;
        8) echo "👋 Goodbye!"; exit 0 ;;
        *) echo "❌ Invalid choice"; show_menu ;;
    esac
}

# Main execution
if [ "$1" = "--all" ]; then
    run_all_checks
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [--all|--help]"
    echo ""
    echo "Options:"
    echo "  --all    Run all diagnostic checks"
    echo "  --help   Show this help message"
    echo ""
    echo "Without options, shows interactive menu"
else
    show_menu
fi
