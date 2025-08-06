#!/data/data/com.termux/files/usr/bin/bash

# Multi-Repository Setup Example
# This script demonstrates how to set up SSH keys for multiple repositories

echo "🔧 Setting up multiple repository access..."

# Configuration for multiple repositories
REPOS=(
    "repo1:git@github.com:username/repo1.git"
    "repo2:git@github.com:username/repo2.git"
    "repo3:git@github.com:username/repo3.git"
)

# Ensure .ssh directory exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Function to setup SSH key for a repository
setup_repo_key() {
    local repo_name="$1"
    local repo_url="$2"
    local key_file="$HOME/.ssh/id_rsa_${repo_name}"
    
    echo "🔑 Setting up key for ${repo_name}..."
    
    # Generate key if it doesn't exist
    if [ ! -f "$key_file" ]; then
        ssh-keygen -t rsa -b 4096 -f "$key_file" -N "" -C "${repo_name}@termux"
        echo "✅ Generated SSH key for ${repo_name}"
    else
        echo "⚠️ SSH key for ${repo_name} already exists"
    fi
    
    # Add to SSH config
    if ! grep -q "Host ${repo_name}.github.com" ~/.ssh/config 2>/dev/null; then
        echo "" >> ~/.ssh/config
        echo "Host ${repo_name}.github.com" >> ~/.ssh/config
        echo "  Hostname ssh.github.com" >> ~/.ssh/config
        echo "  Port 443" >> ~/.ssh/config
        echo "  User git" >> ~/.ssh/config
        echo "  IdentityFile ${key_file}" >> ~/.ssh/config
        echo "  IdentitiesOnly yes" >> ~/.ssh/config
        echo "✅ Added SSH config for ${repo_name}"
    else
        echo "⚠️ SSH config for ${repo_name} already exists"
    fi
    
    # Export public key to storage
    if [ -d ~/storage/shared ]; then
        cp "${key_file}.pub" ~/storage/shared/"id_rsa_${repo_name}.pub"
        echo "📱 Exported public key to: ~/storage/shared/id_rsa_${repo_name}.pub"
    fi
    
    echo "👉 Add the public key to GitHub:"
    echo "   Repository: ${repo_url}"
    echo "   Settings > Deploy keys > Add deploy key"
    echo "   Key content:"
    cat "${key_file}.pub"
    echo ""
}

# Function to clone repository with specific SSH config
clone_repo() {
    local repo_name="$1"
    local repo_url="$2"
    local clone_dir="$HOME/${repo_name}"
    
    echo "📦 Cloning ${repo_name}..."
    
    # Modify URL to use custom host
    local custom_url="${repo_url/github.com/${repo_name}.github.com}"
    
    if [ -d "$clone_dir" ]; then
        echo "⚠️ Directory $clone_dir already exists, skipping clone"
    else
        git clone "$custom_url" "$clone_dir"
        if [ $? -eq 0 ]; then
            echo "✅ Successfully cloned ${repo_name} to ${clone_dir}"
        else
            echo "❌ Failed to clone ${repo_name}"
        fi
    fi
}

# Main setup process
main() {
    echo "🚀 Starting multi-repository setup..."
    
    # Ensure storage is set up
    if [ ! -d ~/storage ]; then
        echo "📱 Setting up storage access..."
        termux-setup-storage
        sleep 2
    fi
    
    # Setup keys for all repositories
    for repo_config in "${REPOS[@]}"; do
        IFS=':' read -r repo_name repo_url <<< "$repo_config"
        setup_repo_key "$repo_name" "$repo_url"
        echo "---"
    done
    
    echo "⏳ Please add all public keys to their respective GitHub repositories..."
    echo "📱 Public keys are available in ~/storage/shared/"
    echo ""
    read -p "Press Enter when you've added all deploy keys to GitHub..."
    
    # Clone all repositories
    for repo_config in "${REPOS[@]}"; do
        IFS=':' read -r repo_name repo_url <<< "$repo_config"
        clone_repo "$repo_name" "$repo_url"
        echo "---"
    done
    
    echo "✅ Multi-repository setup complete!"
    echo ""
    echo "📋 Summary:"
    ls -la ~/id_rsa_* 2>/dev/null || echo "No repositories found"
    echo ""
    echo "🔧 To use different repositories:"
    echo "   cd ~/repo1 && git pull  # Uses repo1 key automatically"
    echo "   cd ~/repo2 && git pull  # Uses repo2 key automatically"
}

# Show usage if no repositories configured
if [ ${#REPOS[@]} -eq 0 ]; then
    echo "❌ No repositories configured!"
    echo "Edit this script and add your repositories to the REPOS array:"
    echo 'REPOS=('
    echo '    "repo1:git@github.com:username/repo1.git"'
    echo '    "repo2:git@github.com:username/repo2.git"'
    echo ')'
    exit 1
fi

# Run main function
main
