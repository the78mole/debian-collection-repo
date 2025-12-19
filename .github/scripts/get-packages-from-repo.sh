#!/bin/bash
# Extract package names from repository Packages file
# Usage: get-packages-from-repo.sh <repo_url> <codename> <arch>

set -e

REPO_URL="$1"
CODENAME="$2"
ARCH="$3"

PACKAGES_URL="${REPO_URL}/dists/${CODENAME}/main/binary-${ARCH}/Packages"

# Download Packages file
if curl -fsSL "${PACKAGES_URL}" -o /tmp/packages.list 2>/dev/null; then
    grep '^Package: ' /tmp/packages.list | awk '{print $2}'
elif curl -fsSL "${PACKAGES_URL}.gz" -o /tmp/packages.list.gz 2>/dev/null; then
    gunzip -c /tmp/packages.list.gz | grep '^Package: ' | awk '{print $2}'
else
    echo "Error: Could not download Packages file from ${PACKAGES_URL}" >&2
    exit 1
fi
