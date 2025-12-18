#!/bin/bash
set -e

# Generate APT repository metadata for multiple distributions and architectures
# Usage: generate-metadata.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

cd "$APT_REPO"

# Define supported distributions and architectures
DISTRIBUTIONS="jammy noble"  # Ubuntu 22.04, 24.04
ARCHITECTURES="amd64 arm64"

echo "Generating repository for distributions: $DISTRIBUTIONS"
echo "Supporting architectures: $ARCHITECTURES"

# Generate Packages files for each distribution and architecture
for dist in $DISTRIBUTIONS; do
    echo ""
    echo "=== Processing distribution: $dist ==="
    
    for arch in $ARCHITECTURES; do
        echo "  Processing architecture: $arch"
        
        # Find packages for this architecture
        if [ -n "$(ls -A pool/main/*_${arch}.deb 2>/dev/null)" ]; then
            dpkg-scanpackages --arch "$arch" --multiversion pool/main > "dists/$dist/main/binary-${arch}/Packages"
            gzip -k -f "dists/$dist/main/binary-${arch}/Packages"
            echo "    Found $(ls pool/main/*_${arch}.deb 2>/dev/null | wc -l) packages for $arch"
        else
            echo "    No packages found for $arch"
            touch "dists/$dist/main/binary-${arch}/Packages"
            gzip -k -f "dists/$dist/main/binary-${arch}/Packages"
        fi
    done
    
    # Also handle architecture-independent packages (all)
    if [ -n "$(ls -A pool/main/*_all.deb 2>/dev/null)" ]; then
        echo "  Found architecture-independent packages"
        # Add 'all' packages to both architectures
        for arch in $ARCHITECTURES; do
            dpkg-scanpackages --arch "$arch" --multiversion pool/main >> "dists/$dist/main/binary-${arch}/Packages"
            gzip -k -f "dists/$dist/main/binary-${arch}/Packages"
        done
    fi
    
    # Generate Release file for this distribution
    echo "  Generating Release file for $dist..."
    cd "dists/$dist"
    
    # Determine distribution details
    case $dist in
        jammy)
            dist_name="Ubuntu 22.04 LTS (Jammy Jellyfish)"
            ;;
        noble)
            dist_name="Ubuntu 24.04 LTS (Noble Numbat)"
            ;;
        *)
            dist_name="$dist"
            ;;
    esac
    
    cat > Release <<EOF
Origin: ${REPO_NAME:-debian-collection-repo}
Label: ${REPO_NAME:-debian-collection-repo} APT Repository
Suite: $dist
Codename: $dist
Architectures: amd64 arm64
Components: main
Description: Multi-architecture Debian package repository for $dist_name
Date: $(date -Ru)
EOF
    
    # Add file hashes
    echo "MD5Sum:" >> Release
    find main -type f | while read file; do
        size=$(stat -c%s "$file")
        hash=$(md5sum "$file" | awk '{print $1}')
        printf " %s %16d %s\n" "$hash" "$size" "$file" >> Release
    done
    
    echo "SHA1:" >> Release
    find main -type f | while read file; do
        size=$(stat -c%s "$file")
        hash=$(sha1sum "$file" | awk '{print $1}')
        printf " %s %16d %s\n" "$hash" "$size" "$file" >> Release
    done
    
    echo "SHA256:" >> Release
    find main -type f | while read file; do
        size=$(stat -c%s "$file")
        hash=$(sha256sum "$file" | awk '{print $1}')
        printf " %s %16d %s\n" "$hash" "$size" "$file" >> Release
    done
    
    cd ../..
done

echo ""
echo "Metadata generation complete!"
echo "Distributions: $DISTRIBUTIONS"
echo "Architectures: $ARCHITECTURES"
