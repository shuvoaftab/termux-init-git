# 🔐 Termux Git Init

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/shuvoaftab/termux-init-git?style=for-the-badge&logo=github&color=brightgreen)](https://github.com/shuvoaftab/termux-init-git/releases)
[![GitHub stars](https://img.shields.io/github/stars/shuvoaftab/termux-init-git?style=for-the-badge&logo=github&color=yellow)](https://github.com/shuvoaftab/termux-init-git/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/shuvoaftab/termux-init-git?style=for-the-badge&logo=github&color=blue)](https://github.com/shuvoaftab/termux-init-git/network)
[![License](https://img.shields.io/github/license/shuvoaftab/termux-init-git?style=for-the-badge&color=orange)](LICENSE)

[![Termux](https://img.shields.io/badge/Termux-Compatible-brightgreen?style=for-the-badge&logo=android&logoColor=white)](https://termux.com/)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com/)
[![SSH](https://img.shields.io/badge/SSH-Secure-blue?style=for-the-badge&logo=openssh&logoColor=white)](https://www.openssh.com/)
[![GitHub](https://img.shields.io/badge/GitHub-Deploy%20Keys-purple?style=for-the-badge&logo=github&logoColor=white)](https://docs.github.com/en/developers/overview/managing-deploy-keys)

[![Shell Script](https://img.shields.io/badge/Shell-Bash-lightgrey?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Security](https://img.shields.io/badge/Security-First-red?style=for-the-badge&logo=security&logoColor=white)](#-security-features)
[![Documentation](https://img.shields.io/badge/Docs-Complete-brightgreen?style=for-the-badge&logo=gitbook&logoColor=white)](#-quick-start)

## The Secure & Shortest Way to Sync Private GitHub Repos in Termux

This project provides automated scripts to securely set up SSH-based Git access in Termux using deploy keys. No passwords, no tokens stored on device – just secure SSH keys that work exclusively with your chosen repository.

## 🎯 What This Project Does

- **Generates SSH keys** specifically for Git operations
- **Configures GitHub SSH access** through port 443 (works behind firewalls)
- **Automatically downloads and sets up** your private repository
- **Manages SSH services** for remote access
- **Exports keys to Android storage** for easy GitHub configuration

## 🛡️ Security Features

✅ **Deploy Key Authentication** - Keys only access specific repositories, not your entire GitHub account  
✅ **No Password Storage** - Uses SSH key-based authentication only  
✅ **Port 443 SSH** - Works through corporate firewalls and restricted networks  
✅ **Automatic Key Management** - Handles SSH config and key permissions  
✅ **Isolated Access** - Each repository can have its own dedicated key  

## 🚀 Quick Start

### Prerequisites

```bash
# Install required packages
pkg update && pkg upgrade
pkg install git openssh curl
```

### Option 1: One-Command Install (Recommended)

```bash
# Download and run the installer
curl -sL https://raw.githubusercontent.com/shuvoaftab/termux-init-git/main/install.sh | bash

# Or download first, then run
wget https://raw.githubusercontent.com/shuvoaftab/termux-init-git/main/install.sh
chmod +x install.sh
./install.sh
```

### Option 2: Manual Setup

#### Step 1: Initialize SSH Keys

```bash
# Download and run the key initialization script
curl -sL https://raw.githubusercontent.com/shuvoaftab/termux-init-git/main/init-keys.sh | bash

# Or download first, then run
wget https://raw.githubusercontent.com/shuvoaftab/termux-init-git/main/init-keys.sh
chmod +x init-keys.sh
./init-keys.sh
```

#### Step 2: Add Deploy Key to GitHub

1. The script exports your public key to `~/storage/shared/id_rsa.pub`
2. Copy this key content
3. Go to your **repo** → **Settings** → **Deploy keys**
4. Click **"Add deploy key"**
5. Name it `Termux` and paste the key
6. ✅ **Check "Allow write access"** if you want to push from Termux
7. Click **"Add key"**

#### Step 3: Clone Your Repository

```bash
# The git-clone.sh script should now be in your current directory
./git-clone.sh
```

## 📋 Detailed Usage

### What `init-keys.sh` Does

1. **Creates SSH directory structure**

   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   ```

2. **Generates RSA 4096-bit key pair**

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
   ```

3. **Sets up storage access**

   ```bash
   termux-setup-storage  # Enables ~/storage/shared access
   ```

4. **Configures SSH for GitHub**

   ```bash
   # Adds to ~/.ssh/config:
   Host github.com
     Hostname ssh.github.com
     Port 443
     User git
     IdentityFile ~/.ssh/id_rsa
   ```

5. **Downloads the clone script** for the next step

### What `git-clone.sh` Does

1. **Verifies SSH authentication** with GitHub (with retries)
2. **Clones your private repository** using SSH
3. **Sets up authorized_keys** for SSH access (if present in repo)
4. **Installs and starts SSH service** (if service script exists in repo)
5. **Logs everything** to `~/git-ssh-setup.log`

### Configuration Options

You can modify these variables in `git-clone.sh`:

```bash
REPO_SSH="git@github.com:your-username/your-repo.git"  # Your repo URL
DEST="$HOME"                                          # Clone destination
RETRIES=5                                            # SSH retry attempts
```

## ⚠️ Important Warnings

### Security Considerations

- **Never share your private key** (`~/.ssh/id_rsa`)
- **Only the public key** (`~/.ssh/id_rsa.pub`) should be added to GitHub
- **Deploy keys are repo-specific** - they can't access other repositories
- **Review the scripts** before running them on your system

### Network Requirements

- Requires internet access for GitHub SSH (ssh.github.com:443)
- Port 443 must be accessible (usually works through corporate firewalls)
- Some networks may block SSH entirely

### Termux Limitations

- Storage permission required for key export
- SSH service requires Termux to stay running in background
- Some Android versions may kill background processes

## 🔧 Advanced Configuration

### Custom Repository

Edit the `REPO_SSH` variable in `git-clone.sh`:

```bash
REPO_SSH="git@github.com:yourusername/yourrepo.git"
```

### Multiple Repositories

For multiple repos, create separate key pairs:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_repo1 -N ""
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_repo2 -N ""
```

Add each to your SSH config:

```bash
Host repo1.github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_rsa_repo1

Host repo2.github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_rsa_repo2
```

### Debug SSH Issues

```bash
# Test SSH connection with verbose output
ssh -vT git@github.com

# Check if key is loaded
ssh-add -l

# Test with specific key
ssh -i ~/.ssh/id_rsa -T git@github.com
```

## 📊 Logging and Troubleshooting

### Log Files

- **Setup log**: `~/git-ssh-setup.log` - Contains all setup operations and errors
- **SSH debug**: Use `GIT_TRACE=1 GIT_SSH_COMMAND="ssh -v"` for verbose Git operations

### Common Issues

**"Permission denied (publickey)"**

- Verify the public key is added to GitHub Deploy keys
- Check SSH config syntax in `~/.ssh/config`
- Ensure private key permissions: `chmod 600 ~/.ssh/id_rsa`

**"Repository not found"**

- Verify deploy key has correct repository access
- Check if repository URL is correct in `git-clone.sh`
- Ensure deploy key has write access if pushing

**Storage access denied**

- Run `termux-setup-storage` manually
- Grant Termux storage permission in Android settings

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on:

- Reporting bugs
- Suggesting enhancements
- Submitting pull requests
- Code style guidelines

## 👨‍💻 Author & Maintainer

<div align="center">

### Shuvo Aftab

[![GitHub](https://img.shields.io/badge/GitHub-shuvoaftab-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/shuvoaftab)
[![Profile Views](https://komarev.com/ghpvc/?username=shuvoaftab&style=for-the-badge&color=brightgreen)](https://github.com/shuvoaftab)

**Passionate Android Developer & Security Enthusiast**

*Specializing in WordPress, Development, Automation, IoT, Emails, Customer Support, and to be continued!*

</div>

---

<details>
<summary><b>🚀 About the Author</b></summary>

<br>

**Shuvo Aftab** is a dedicated software developer with extensive experience in:

- **🌐 WordPress Development** - Creating powerful websites and custom solutions
- **� Full-Stack Development** - Building comprehensive web and mobile applications
- **⚡ Automation & Scripting** - Streamlining workflows and developer productivity
- **🌐 IoT Solutions** - Connecting devices and creating smart systems
- **� Email Systems** - Designing and managing communication platforms
- **🎧 Customer Support** - Providing technical assistance and user experience optimization
- **🔒 Security Engineering** - Implementing secure authentication and deployment systems

### 🎯 Expertise Areas

| Domain | Technologies |
|--------|-------------|
| **Web Development** | WordPress, PHP, JavaScript, HTML/CSS |
| **Mobile & Terminal** | Android, Termux, Mobile Security |
| **Automation** | Bash, Shell Scripts, CI/CD, Git |
| **IoT & Hardware** | Embedded Systems, Device Integration |
| **Communication** | Email Systems, Customer Support Tools |
| **Security** | SSH, Deploy Keys, Authentication |

### 🌟 Project Philosophy

> *"Security should be simple, not simplified."*

This project embodies the principle that powerful security tools should be accessible to everyone, regardless of technical background. By automating complex SSH configurations while maintaining transparency and security best practices, we democratize secure development workflows.

### 📫 Connect & Collaborate

- **💼 Professional**: Open to collaboration on security and mobile projects
- **🤝 Mentoring**: Available for guidance on Android development and security
- **💡 Ideas**: Always interested in discussing innovative automation solutions
- **🐛 Issues**: Responsive to bug reports and feature requests

### 🏆 Project Stats

![GitHub Stats](https://github-readme-stats.vercel.app/api?username=shuvoaftab&show_icons=true&theme=radical&hide_border=true)

</details>

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the Termux community
- Inspired by the need for secure, automated Git setup in Android environments
- Thanks to all contributors and testers

---

**⭐ Star this repo if it helped you secure your Termux Git workflow!**
