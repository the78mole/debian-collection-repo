#!/bin/bash
set -e

# Organize packages into distribution-specific directories
# Usage: organize-packages.sh <downloads-dir> <apt-repo-dir>

DOWNLOADS_DIR="${1:-downloads}"
APT_REPO="${2:-apt-repo}"

if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo "Error: Downloads directory $DOWNLOADS_DIR not found"
    exit 1
fi

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

# Define distribution mappings
declare -A DIST_KEYWORDS
DIST_KEYWORDS[jammy]="jammy|ubuntu22.04|ubuntu-22.04|22.04"
DIST_KEYWORDS[noble]="noble|ubuntu24.04|ubuntu-24.04|24.04"
DIST_KEYWORDS[bookworm]="bookworm|debian12|debian-12"
DIST_KEYWORDS[trixie]="trixie|debian13|debian-13"

DISTRIBUTIONS="jammy noble bookworm trixie"

echo "Organizing packages by distribution..."

# Function to detect distribution from package
detect_distribution() {
    local deb_file="$1"
    local filename=$(basename "$deb_file")
    local detected_dists=""
    
    # Try to extract control file and check for distribution info
    local control_content=$(dpkg-deb --field "$deb_file" 2>/dev/null || echo "")
    
    # Check filename and control content for distribution keywords
    for dist in $DISTRIBUTIONS; do
        local keywords="${DIST_KEYWORDS[$dist]}"
        if echo "$filename" | grep -qiE "$keywords"; then
            detected_dists="$detected_dists $dist"
        elif echo "$control_content" | grep -qiE "$keywords"; then
            detected_dists="$detected_dists $dist"
        fi
    done
    
    # If no specific distribution detected, check for generic ubuntu/debian markers
    if [ -z "$detected_dists" ]; then
        if echo "$filename" | grep -qiE "ubuntu"; then
            detected_dists="jammy noble"
        elif echo "$filename" | grep -qiE "debian"; then
            detected_dists="bookworm trixie"
        fi
    fi
    
    # If still nothing detected, use all distributions
    if [ -z "$detected_dists" ]; then
        detected_dists="$DISTRIBUTIONS"
    fi
    
    echo "$detected_dists"
}

# Process each .deb file
for deb_file in "$DOWNLOADS_DIR"/*.deb; do
    if [ ! -f "$deb_file" ]; then
        echo "No .deb files found in $DOWNLOADS_DIR"
        break
    fi
    
    filename=$(basename "$deb_file")
    echo "Processing: $filename"
    
    # Detect which distributions this package is for
    target_dists=$(detect_distribution "$deb_file")
    echo "  → Target distributions: $target_dists"
    
    # Copy to each target distribution's pool
    for dist in $target_dists; do
        target_dir="$APT_REPO/pool/$dist/main"
        mkdir -p "$target_dir"
        cp "$deb_file" "$target_dir/"
    done
done

echo ""
echo "Package organization complete!"
echo "Summary by distribution:"
for dist in $DISTRIBUTIONS; do
    pool_dir="$APT_REPO/pool/$dist/main"
    if [ -d "$pool_dir" ]; then
        count=$(ls -1 "$pool_dir"/*.deb 2>/dev/null | wc -l)
        echo "  $dist: $count packages"
    else
        echo "  $dist: 0 packages"
    fi
done
