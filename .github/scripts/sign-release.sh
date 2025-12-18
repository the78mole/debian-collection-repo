#!/bin/bash
set -e

# Sign APT repository Release file with GPG
# Usage: sign-release.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

if [ -z "$GPG_KEY_ID" ]; then
    echo "Error: GPG_KEY_ID environment variable not set"
    exit 1
fi

cd "$APT_REPO/dists/stable"

echo "Signing Release file with GPG key $GPG_KEY_ID..."
gpg --default-key "$GPG_KEY_ID" -abs -o Release.gpg Release
gpg --default-key "$GPG_KEY_ID" -abs --clearsign -o InRelease Release

echo "Release file signed successfully"
