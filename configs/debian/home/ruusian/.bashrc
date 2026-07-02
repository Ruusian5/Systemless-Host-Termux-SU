# --- DEBIAN HUD PERFORMANCE CONFIG ---
export PATH=~/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/.opencode/bin
export PATH="$HOME/.local/bin:$PATH"
export TMPDIR=/tmp
export DISPLAY=:0
export PULSE_SERVER=tcp:127.0.0.1:4713
export XDG_RUNTIME_DIR=/run/user/1000
export ESPEAK_DATA_DIR=/usr/lib/aarch64-linux-gnu/espeak-ng-data

# MESA ZINK HARDWARE ACCELERATION
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export TU_DEBUG=noconform
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json
export ZINK_DESCRIPTORS=lazy
export MESA_VK_WSI_PRESENT_MODE=immediate
export LIBGL_DRIVERS_PATH=/usr/lib/aarch64-linux-gnu/dri
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu
export MESA_SHADER_CACHE_DISABLE=false
export MESA_SHADER_CACHE_MAX_SIZE=1G

# ALIASES
alias check-gpu="glxinfo -B | grep renderer"
alias tsu="/data/data/com.termux/files/usr/bin/su"
alias tam="/system/bin/am"
alias htop="htop"

# Auto-fix after reboot
test -x /usr/local/bin/fix-chroot.sh && /usr/local/bin/fix-chroot.sh >/dev/null 2>&1
