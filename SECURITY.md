# 🛡 Security Policy

## Supported Versions
Only the latest release (`v0.1` and above) is currently receiving security updates.

## Privilege Escalation
This project requires SuperUser (Root) access to mount hardware nodes and bypass Android's `nosuid` filesystem restrictions. 
- Scripts strictly limit root execution payloads.
- The Debian guest user (`ruusian`) is configured with `NOPASSWD` sudo access *only* for specific workstation commands via `/etc/sudoers.d/`.

## Reporting a Vulnerability
If you discover a security vulnerability (e.g., an unintended privilege escalation vector from the guest to the host, or a dangerous exposed socket), please open a private security advisory on GitHub or contact the maintainer directly. Do not publicly disclose the exploit until a patch has been deployed.
