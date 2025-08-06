# Contributing to Termux Git Init

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## 🚀 Quick Contributing Guide

### Reporting Bugs

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/shuvoaftab/termux-init-git/issues).

**Great Bug Reports** include:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run script with '...'
2. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Environment:**
- Termux version: [e.g. 0.118.0]
- Android version: [e.g. Android 12]
- Device: [e.g. Samsung Galaxy S21]
- Architecture: [e.g. aarch64]

**Logs**
```bash
# Include relevant logs from ~/git-ssh-setup.log
```

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

We welcome enhancement suggestions! Enhancement suggestions are tracked as GitHub issues.

**Great Enhancement Suggestions** include:

- **Use a clear and descriptive title** for the issue
- **Provide a step-by-step description** of the suggested enhancement
- **Provide specific examples** to demonstrate the steps
- **Describe the current behavior** and **explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful** to most users

## 🛠️ Development Setup

### Prerequisites

- Termux environment for testing
- Git installed
- Basic shell scripting knowledge

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub, then:
   git clone https://github.com/YOUR_USERNAME/termux-init-git.git
   cd termux-init-git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Edit the scripts
   - Test thoroughly in Termux environment
   - Update documentation if needed

4. **Test your changes**
   ```bash
   # Test init-keys.sh
   ./init-keys.sh

   # Test git-clone.sh (after setting up deploy key)
   ./git-clone.sh

   # Check logs
   cat ~/git-ssh-setup.log
   ```

### Code Style Guidelines

#### Shell Script Best Practices

1. **Use proper shebang**
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   ```

2. **Add error handling**
   ```bash
   set -e  # Exit on any error
   
   # Or handle errors explicitly
   if ! command; then
       echo "Error: command failed"
       exit 1
   fi
   ```

3. **Use meaningful variable names**
   ```bash
   # Good
   SSH_KEY_PATH="~/.ssh/id_rsa_git"
   REPO_URL="git@github.com:user/repo.git"
   
   # Avoid
   KEY="~/.ssh/id_rsa_git"
   URL="git@github.com:user/repo.git"
   ```

4. **Quote variables**
   ```bash
   # Good
   if [ -f "$SSH_KEY_PATH" ]; then
   
   # Avoid
   if [ -f $SSH_KEY_PATH ]; then
   ```

5. **Add comments for complex logic**
   ```bash
   # Retry SSH authentication up to RETRIES times
   # This handles cases where GitHub SSH isn't immediately ready
   retry_ssh_check() {
       local attempt=1
       until ssh -T -p 443 git@ssh.github.com 2>&1 | grep -q "successfully authenticated"; do
           # ... implementation
       done
   }
   ```

#### Documentation Style

1. **Use consistent markdown formatting**
2. **Include code examples for all features**
3. **Keep explanations clear and concise**
4. **Add emojis for visual appeal (but don't overuse)**

### Testing Guidelines

#### Manual Testing Checklist

- [ ] Script runs without errors in fresh Termux installation
- [ ] SSH key generation works correctly
- [ ] GitHub SSH authentication succeeds
- [ ] Repository cloning works
- [ ] Proper file permissions are set
- [ ] Logging captures all operations
- [ ] Error handling works for common failure cases

#### Test Scenarios

1. **Fresh Installation**
   - Clean Termux environment
   - No existing SSH keys
   - No storage access granted

2. **Existing SSH Setup**
   - SSH keys already present
   - Existing `.ssh/config` file
   - Previous GitHub authentication

3. **Network Issues**
   - Intermittent connectivity
   - Firewall blocking SSH
   - GitHub temporarily unavailable

4. **Permission Issues**
   - Storage access denied
   - Incorrect file permissions
   - Read-only filesystem

## 📝 Pull Request Process

1. **Ensure your PR addresses an open issue** (create one if it doesn't exist)

2. **Update documentation** for any new features or changed behavior

3. **Add or update tests** if applicable

4. **Follow the code style guidelines** outlined above

5. **Write a clear PR description** that includes:
   - What changes you made
   - Why you made them
   - How to test the changes
   - Any breaking changes

6. **Reference related issues** using keywords like "fixes #123"

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Related Issue
Fixes #(issue number)

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tested in clean Termux environment
- [ ] Tested with existing SSH setup
- [ ] Tested error handling
- [ ] Updated documentation

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have tested this thoroughly
```

## 🔍 Code Review Process

1. **All PRs require at least one review** from a maintainer
2. **Reviews focus on:**
   - Code correctness and security
   - Adherence to style guidelines
   - Documentation completeness
   - Test coverage
3. **Address review comments** promptly and thoroughly
4. **Squash commits** before merging if requested

## 🎯 Areas Where We Need Help

### High Priority
- **Testing on different Android versions** and devices
- **Improving error messages** and user guidance
- **Adding support for different Git hosting services** (GitLab, Bitbucket)
- **Performance optimizations** for slow networks

### Medium Priority
- **Additional authentication methods** (GitHub CLI, tokens)
- **Automated testing** setup
- **Multi-repository management** features
- **Configuration file support**

### Low Priority
- **GUI frontend** for non-technical users
- **Integration with Termux widgets**
- **Advanced SSH configuration options**

## 🏷️ Issue Labels

We use these labels to organize issues:

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `question` - Further information is requested
- `documentation` - Improvements or additions to documentation
- `testing` - Related to testing and QA

## 📋 Release Process

1. **Version bumps** follow semantic versioning
2. **Changelog** is updated for each release
3. **Testing** on multiple devices before release
4. **GitHub releases** include:
   - Release notes
   - Breaking changes (if any)
   - Installation instructions

## 🤝 Community Guidelines

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- The use of sexualized language or imagery
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

## 📞 Contact

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For general questions and community chat
- **Email**: [maintainer email if available]

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Special thanks in major releases

---

**Thank you for contributing to Termux Git Init! 🚀**
