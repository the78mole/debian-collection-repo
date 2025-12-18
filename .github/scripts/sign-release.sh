#!/bin/bash
set -e

# Sign APT repository Release files with GPG for all distributions
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

# Define supported distributions
DISTRIBUTIONS="jammy noble"

echo "Signing Release files with GPG key $GPG_KEY_ID..."

for dist in $DISTRIBUTIONS; do
    if [ -f "$APT_REPO/dists/$dist/Release" ]; then
        echo "  Signing $dist..."
        cd "$APT_REPO/dists/$dist"
        gpg --default-key "$GPG_KEY_ID" -abs -o Release.gpg Release
        gpg --default-key "$GPG_KEY_ID" -abs --clearsign -o InRelease Release
        cd ../../..
    else
        echo "  Warning: Release file not found for $dist"
    fi
done

echo "Release files signed successfully for all distributions"
