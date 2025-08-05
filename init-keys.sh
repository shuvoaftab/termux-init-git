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

# Copy public key to shared storage
# termux-setup-storage
cp "$KEY.pub" ~/storage/shared/id_rsa_git.pub

# SSH config
echo "
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile $KEY
" >> ~/.ssh/config

chmod 600 ~/.ssh/config

echo "✅ Public key exported to Android storage."
echo "👉 Please add this key to GitHub (Settings > Deploy Keys) for your private repo."
echo "🔁 After that, run the second script to clone."
