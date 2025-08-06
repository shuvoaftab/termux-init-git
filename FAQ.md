# 🙋 Frequently Asked Questions (FAQ)

## General Questions

### What is termux-init-git?
Termux-init-git is a collection of scripts that automate the setup of secure SSH-based Git access in Termux (Android terminal emulator). It generates SSH keys, configures GitHub access, and sets up your private repositories for seamless cloning and syncing.

### Why should I use this instead of HTTPS authentication?
- **More secure**: No passwords or tokens stored on device
- **Deploy keys**: Repository-specific access (doesn't compromise your entire GitHub account)
- **Firewall-friendly**: Uses port 443 which works through corporate firewalls
- **Automated**: One-command setup vs manual configuration

### Is this safe to use?
Yes, when used properly:
- Scripts are open source and reviewable
- Uses industry-standard SSH key authentication
- Deploy keys limit access to specific repositories only
- No sensitive data is transmitted or stored insecurely

## Setup and Installation

### Do I need root access?
No, these scripts work in standard Termux without root access.

### What Android versions are supported?
The scripts work on any Android version that supports Termux (Android 7+). However, background process management varies between Android versions.

### Can I use this with multiple repositories?
Yes, but you'll need to:
1. Generate separate SSH keys for each repo
2. Modify the SSH config accordingly
3. Update the repository URL in `git-clone.sh`

See the [Advanced Configuration](README.md#advanced-configuration) section for details.

### What if I already have SSH keys?
The script will detect existing keys and skip generation. It will only create new keys if `~/.ssh/id_rsa` doesn't exist.

## Troubleshooting

### "Permission denied (publickey)" error
**Causes:**
- Deploy key not added to GitHub
- Wrong repository in git-clone.sh
- Incorrect SSH configuration

**Solutions:**
```bash
# Test SSH connection
ssh -T git@github.com

# Check if key is loaded
ssh-add -l

# Verify GitHub SSH settings
ssh -vT git@github.com
```

### "Repository not found" error
**Causes:**
- Deploy key doesn't have access to the repository
- Repository URL is incorrect
- Repository is private but deploy key lacks access

**Solutions:**
1. Verify deploy key is added to the correct repository
2. Check if deploy key has write access (if needed)
3. Confirm repository URL in `git-clone.sh`

### Storage permission denied
**Causes:**
- Termux doesn't have storage permission
- `termux-setup-storage` wasn't run

**Solutions:**
```bash
# Grant storage permission
termux-setup-storage

# Check Android settings: Apps > Termux > Permissions > Storage
```

### SSH service won't start
**Causes:**
- SSH service script not found in repository
- Incorrect repository structure
- Permission issues

**Solutions:**
1. Ensure your repository has the SSH service script at the expected path
2. Check the `SSH_SERVICE_SCRIPT` variable in `git-clone.sh`
3. Verify script has execute permissions

### Script hangs during GitHub authentication
**Causes:**
- Network connectivity issues
- GitHub SSH servers temporarily unavailable
- Firewall blocking SSH traffic

**Solutions:**
```bash
# Test direct connection
ssh -T -p 443 git@ssh.github.com

# Check network connectivity
ping github.com

# Try with verbose logging
GIT_SSH_COMMAND="ssh -v" git clone [repo-url]
```

## GitHub and Deploy Keys

### What's the difference between deploy keys and personal access tokens?
| Feature | Deploy Keys | Personal Access Tokens |
|---------|-------------|------------------------|
| Scope | Single repository | Multiple repositories |
| Security | Higher (repo-specific) | Lower (account-wide) |
| Revocation | Per-repository | Account-wide |
| Setup | More complex | Simpler |

### Can I use the same deploy key for multiple repositories?
No, GitHub requires unique deploy keys per repository. You'll need separate keys for each repo.

### How do I rotate/change SSH keys?
1. Generate new SSH key pair
2. Add new public key as deploy key to GitHub
3. Update local SSH configuration
4. Remove old deploy key from GitHub
5. Delete old key files

### What permissions does a deploy key need?
- **Read access**: Always granted, allows cloning and pulling
- **Write access**: Optional, required for pushing changes

## Network and Connectivity

### Why use port 443 instead of 22?
Port 443 (HTTPS) is rarely blocked by firewalls, while port 22 (SSH) is often restricted in corporate/school networks.

### Will this work on mobile data?
Yes, but be aware of:
- Data usage for repository syncing
- Potential NAT/firewall restrictions
- Carrier-specific blocking (rare)

### Can I use this behind a proxy?
SSH doesn't support HTTP proxies directly. You would need:
- SOCKS proxy support in SSH
- ProxyCommand configuration
- Alternative: Use HTTPS Git with proxy settings

## Advanced Usage

### How can I automate the entire process?
You can't fully automate it because adding the deploy key to GitHub requires manual action (for security). However, you can:
1. Pre-generate keys and add them to GitHub
2. Script the repository cloning part
3. Use GitHub CLI for deploy key management (requires different setup)

### Can I use this for GitLab/Bitbucket?
The scripts are GitHub-specific but can be adapted:
- Change SSH hostnames and ports
- Modify authentication testing
- Update repository URLs

### How do I backup my SSH keys?
```bash
# Copy keys to safe location
cp ~/.ssh/id_rsa* /path/to/backup/

# Or export to Android storage
cp ~/.ssh/id_rsa* ~/storage/shared/
```

**⚠️ Warning**: Keep private keys secure and encrypted during backup!

### Can I run multiple Termux sessions with different keys?
Yes, by using different SSH config entries:
```bash
Host repo1.github.com
  Hostname ssh.github.com
  Port 443
  IdentityFile ~/.ssh/id_rsa_repo1

Host repo2.github.com
  Hostname ssh.github.com
  Port 443
  IdentityFile ~/.ssh/id_rsa_repo2
```

## Performance and Optimization

### The script is slow. How can I speed it up?
- **Network**: Use WiFi instead of mobile data
- **Retries**: Reduce RETRIES variable in git-clone.sh
- **Logging**: Disable verbose logging by removing GIT_TRACE
- **Repository size**: Clone specific branches instead of full history

### How much data does the initial clone use?
Depends on repository size:
- Small repositories (< 10MB): Minimal data usage
- Large repositories (> 100MB): Consider shallow clones
- Use `git clone --depth 1` for latest commit only

## Security Concerns

### What if my phone is stolen?
1. **Immediate**: Revoke deploy keys from GitHub
2. **Device encryption**: Protects keys if device is encrypted
3. **Remote wipe**: Use Find My Device if available
4. **Re-setup**: Generate new keys on replacement device

### Should I set a passphrase on SSH keys?
**Pros**: Additional security if device is compromised
**Cons**: Need to enter passphrase for each Git operation

For automated scripts, passwordless keys are more practical.

### Can malicious apps access my SSH keys?
- **Non-rooted devices**: Apps run in sandboxes, limited access
- **Rooted devices**: Higher risk, malicious apps could potentially access keys
- **Mitigation**: Use device encryption, avoid rooting if possible

## Getting Help

### Where can I get support?
1. **Check this FAQ** first
2. **Search existing issues** on GitHub
3. **Create a new issue** with detailed information
4. **Include logs** from `~/git-ssh-setup.log`

### How do I report bugs?
See our [Contributing Guide](CONTRIBUTING.md) for detailed bug reporting instructions.

### What information should I include when asking for help?
- Termux version (`termux-info`)
- Android version and device model
- Complete error messages
- Relevant log entries from `~/git-ssh-setup.log`
- Steps to reproduce the issue

---

**💡 Can't find your question? [Open an issue](https://github.com/shuvoaftab/termux-init-git/issues) and we'll add it to the FAQ!**
