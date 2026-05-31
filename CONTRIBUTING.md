# 🤝 Contributing

We welcome contributions to the **Systemless-Host-Termux-SU** project! 

## Guidelines
1. **Idempotency**: All new scripts and configurations must be idempotent. If a script is run twice, the second run should safely report "already configured" without causing errors.
2. **Error Handling**: Use `set -euo pipefail` in all bash scripts. Ensure no command fails silently unless intentionally suppressed with `|| true`.
3. **GPU First**: If you add a new graphical application, ensure it has the correct flags to utilize the established `Zink` / `Turnip` pipeline.
4. **Testing**: Test your changes on both fresh environments and existing installations.

To submit code:
1. Fork the repository.
2. Create a feature branch.
3. Submit a Pull Request with a detailed description of the changes.
