#!/bin/bash
set -euo pipefail

TOKEN="${GITHUB_TOKEN:-}"
REPO="Ruusian5/Systemless-Host-Termux-SU"
TAG="v0.1.0-offline"

echo "[+] Creating GitHub Release $TAG..."
RELEASE_RES=$(curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO/releases \
  -d '{
    "tag_name": "'"$TAG"'",
    "target_commitish": "main",
    "name": "Hardened Enterprise Offline Deployment v0.1.0",
    "body": "Complete offline workstation snapshot with full Zink+Turnip GPU acceleration, pre-configured development stack (Node, NPM, Python, C++), and disaster recovery tools.",
    "draft": false,
    "prerelease": false
  }')

RELEASE_ID=$(echo "$RELEASE_RES" | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',\n')

if [ -z "$RELEASE_ID" ]; then
    echo "[!] Failed to create release. Response:"
    echo "$RELEASE_RES"
    exit 1
fi

echo "[✓] Created Release ID: $RELEASE_ID"

upload_asset() {
    FILE_PATH=$1
    FILE_NAME=$(basename "$FILE_PATH")
    echo "[+] Uploading $FILE_NAME ..."
    curl -s -X POST \
      -H "Authorization: token $TOKEN" \
      -H "Content-Type: application/octet-stream" \
      --data-binary @"$FILE_PATH" \
      "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$FILE_NAME" > /dev/null
    echo "[✓] Uploaded $FILE_NAME"
}

cd ~/offline-release

# Generate checksums
echo "[+] Generating SHA256 checksums..."
sha256sum * > checksums.sha256

# Ensure compression finishes before we run this script. We assume it's done when we run it.
upload_asset package-manifest.txt
upload_asset environment-report.txt
upload_asset gpu-report.txt
upload_asset checksums.sha256

echo "[+] Starting large upload for debian-rootfs.tar.zst..."
nohup upload_asset debian-rootfs.tar.zst > "$HOME/offline-release/upload.log" 2>&1 &

echo "[✓] All assets uploaded. Offline deployment release published!"
