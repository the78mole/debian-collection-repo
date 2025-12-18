#!/bin/bash
set -e

# Generate front page index.html for apt-repo using Jinja template
# Usage: generate-frontpage.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

# Call Python script to render template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/render-frontpage.py" "$APT_REPO" "$APT_REPO/index.html"

