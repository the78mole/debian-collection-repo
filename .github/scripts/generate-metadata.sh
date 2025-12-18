#!/bin/bash
set -e

# Generate APT repository metadata
# Usage: generate-metadata.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

cd "$APT_REPO"

# Generate Packages file for binary-amd64
echo "Generating Packages file..."
if [ -n "$(ls -A pool/main/*.deb 2>/dev/null)" ]; then
    dpkg-scanpackages --multiversion pool/main > dists/stable/main/binary-amd64/Packages
    gzip -k -f dists/stable/main/binary-amd64/Packages
else
    echo "No packages to scan"
    touch dists/stable/main/binary-amd64/Packages
    gzip -k -f dists/stable/main/binary-amd64/Packages
fi

# Generate Release file
echo "Generating Release file..."
cd dists/stable
cat > Release <<EOF
Origin: ${REPO_NAME:-debian-collection-repo}
Label: ${REPO_NAME:-debian-collection-repo} APT Repository
Suite: stable
Codename: stable
Architectures: amd64
Components: main
Description: Multi-project Debian package repository
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

echo "Metadata generation complete"
