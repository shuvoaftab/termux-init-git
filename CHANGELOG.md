# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation and README
- Contributing guidelines
- Security policy
- Changelog
- Enhanced error handling and logging

## [1.0.0] - 2025-01-XX

### Added
- Initial release of termux-init-git
- `init-keys.sh` script for SSH key generation and setup
- `git-clone.sh` script for repository cloning and SSH service setup
- Automatic GitHub SSH configuration (port 443)
- Storage access setup for Android
- Deploy key support for secure repository access
- Comprehensive logging system
- Retry mechanism for SSH authentication
- Authorized keys management
- SSH service installation and startup

### Features
- **Secure SSH Setup**: Generate RSA 4096-bit keys for Git operations
- **GitHub Integration**: Automatic configuration for GitHub SSH access
- **Android Integration**: Export keys to Android storage for easy access
- **Error Handling**: Robust error handling with retry mechanisms
- **Logging**: Comprehensive logging to `~/git-ssh-setup.log`
- **Service Management**: Automatic SSH service setup and startup
- **Port 443 Support**: Works through corporate firewalls

### Security
- Deploy key authentication (repository-specific access)
- No password storage - SSH key-based only
- Proper file permissions for SSH keys and config
- Isolated repository access

## [0.1.0] - Initial Development

### Added
- Basic script structure
- Core SSH key generation functionality
- Initial GitHub configuration

---

## Release Notes

### Version 1.0.0

This is the first stable release of termux-init-git. The scripts have been thoroughly tested and provide a secure, automated way to set up Git access in Termux using SSH deploy keys.

**Key Features:**
- One-command setup for SSH keys and GitHub access
- Secure deploy key authentication
- Works through restrictive firewalls (port 443)
- Comprehensive error handling and logging
- Android storage integration

**Breaking Changes:**
- None (initial release)

**Migration Guide:**
- No migration needed (initial release)

**Known Issues:**
- Requires manual deploy key addition to GitHub (by design for security)
- SSH service requires Termux to remain running in background
- Some Android versions may aggressively kill background processes

---

## Contribution Notes

When updating this changelog:

1. **Keep the format consistent** with [Keep a Changelog](https://keepachangelog.com/)
2. **Use semantic versioning** for all releases
3. **Include all user-facing changes** in the appropriate category:
   - `Added` for new features
   - `Changed` for changes in existing functionality
   - `Deprecated` for soon-to-be removed features
   - `Removed` for now removed features
   - `Fixed` for any bug fixes
   - `Security` for security-related changes

4. **Date releases** when they are published
5. **Link to issues/PRs** where relevant
6. **Keep unreleased section** at the top for ongoing development
