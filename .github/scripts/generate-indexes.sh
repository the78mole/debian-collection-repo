#!/bin/bash
set -e

# Generate directory index files for all folders in apt-repo using Jinja template
# Usage: generate-indexes.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

# Call Python script to render templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/render-indexes.py" "$APT_REPO"

