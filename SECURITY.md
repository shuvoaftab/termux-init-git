# Security Policy

## Supported Versions

We actively support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability, please follow these steps:

### 🚨 For Security Issues - DO NOT create a public issue

1. **Email us directly** at [security contact] or create a private security advisory
2. **Provide detailed information** about the vulnerability
3. **Include steps to reproduce** if possible
4. **Wait for our response** before public disclosure

### What to Include

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** and affected components
- **Suggested fix** if you have one
- **Your contact information** for follow-up questions

### Response Timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 1 week
- **Fix timeline**: Depends on severity (critical issues within 72 hours)

## Security Considerations

### SSH Key Security

- **Private keys** (`~/.ssh/id_rsa`) should never be shared
- **Public keys** are safe to share but should only be added to intended repositories
- **Key rotation** should be performed regularly for high-security environments

### Script Security

- **Always review** scripts before running them
- **Verify checksums** if downloading from third-party sources
- **Use HTTPS** for script downloads when possible

### Deploy Key Best Practices

- **Use separate deploy keys** for each repository
- **Grant minimal permissions** (read-only if pushing isn't needed)
- **Rotate keys** periodically
- **Monitor key usage** in GitHub's security logs

### Termux-Specific Security

- **Keep Termux updated** to latest version
- **Review installed packages** regularly
- **Use app lock** if device supports it
- **Enable device encryption** for additional security

## Known Security Considerations

### Network Security

- **SSH traffic** is encrypted but metadata is visible
- **GitHub's SSH fingerprints** should be verified on first connection
- **Man-in-the-middle attacks** are possible on compromised networks

### Android Security

- **Root access** can compromise all keys and data
- **Malicious apps** may be able to access Termux data on rooted devices
- **Device loss** could expose SSH keys if device isn't encrypted

### Script Dependencies

- **curl/wget** downloads could be intercepted (use HTTPS)
- **GitHub's raw content** should be verified for integrity
- **Network dependencies** create potential attack vectors

## Mitigation Strategies

1. **Use device encryption** and strong lock screens
2. **Regularly update** all software components
3. **Monitor GitHub security logs** for unauthorized access
4. **Use separate keys** for different environments (dev/prod)
5. **Implement key rotation** policies
6. **Review script sources** before execution

## Security Hardening

### Additional SSH Security

```bash
# Add to ~/.ssh/config for additional security
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  StrictHostKeyChecking yes
  UserKnownHostsFile ~/.ssh/known_hosts
```

### File Permissions

```bash
# Ensure proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/config
chmod 644 ~/.ssh/known_hosts
```

### Monitoring

```bash
# Check for unauthorized key usage
# Monitor GitHub's security log regularly
# Check SSH auth logs in Termux
```

## Responsible Disclosure

We follow responsible disclosure practices:

1. **Private reporting** of vulnerabilities
2. **Coordination** with affected parties
3. **Public disclosure** only after fixes are available
4. **Credit** to security researchers (with permission)

## Security Resources

- [GitHub SSH Security](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [SSH Best Practices](https://wiki.mozilla.org/Security/Guidelines/OpenSSH)
- [Android Security](https://source.android.com/security)
- [Termux Security](https://wiki.termux.com/wiki/Main_Page)

---

**Report security issues responsibly. Help us keep the community safe! 🔒**
