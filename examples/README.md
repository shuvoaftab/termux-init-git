# 📚 Usage Examples

This directory contains practical examples of how to use and extend termux-init-git for different scenarios.

## Files

- `multi-repo-setup.sh` - Set up multiple repositories with separate SSH keys
- `custom-config.sh` - Example of customizing the scripts for your needs
- `troubleshooting.sh` - Common debugging commands and solutions
- `backup-restore.sh` - How to backup and restore SSH configurations

## Quick Examples

### Basic Usage
```bash
# Download and run setup
curl -sL https://raw.githubusercontent.com/shuvoaftab/termux-init-git/main/init-keys.sh | bash

# Add deploy key to GitHub, then:
./git-clone.sh
```

### Custom Repository
```bash
# Edit git-clone.sh before running
sed -i 's|git@github.com:android-research/termux-namp.git|git@github.com:yourusername/yourrepo.git|' git-clone.sh
./git-clone.sh
```

### Testing SSH Connection
```bash
# Test GitHub SSH access
ssh -T git@github.com

# Test with verbose output
ssh -vT git@github.com

# Test specific key
ssh -i ~/.ssh/id_rsa -T git@github.com
```

---

See individual files for detailed examples and explanations.
