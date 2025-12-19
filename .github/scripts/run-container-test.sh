#!/bin/bash
# Script to run package installation tests in Docker containers
# Usage: run-container-test.sh <distro> <version> <codename> <arch> <repo_url> <repo_name>

set -e

DISTRO="$1"
VERSION="$2"
CODENAME="$3"
ARCH="$4"
REPO_URL="$5"
REPO_NAME="$6"

# Determine platform for Docker
PLATFORM="$ARCH"
if [ "$PLATFORM" = "amd64" ]; then
  PLATFORM="linux/amd64"
elif [ "$PLATFORM" = "arm64" ]; then
  PLATFORM="linux/arm64"
fi

# Determine base image
if [ "$DISTRO" = "ubuntu" ]; then
  BASE_IMAGE="ubuntu:${VERSION}"
else
  BASE_IMAGE="debian:${CODENAME}"
fi

echo "Testing on $BASE_IMAGE ($PLATFORM)"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get list of packages from repository
echo "=== Fetching package list from repository ==="
chmod +x "${SCRIPT_DIR}/get-packages-from-repo.sh"
PACKAGES=$("${SCRIPT_DIR}/get-packages-from-repo.sh" "$REPO_URL" "$CODENAME" "$ARCH" 2>/dev/null) || {
  echo "⚠️  No packages found in repository for ${CODENAME}/${ARCH}"
  echo "Running basic repository verification instead..."
  
  docker run --platform="$PLATFORM" --rm \
    -v "${SCRIPT_DIR}/test-installation.sh:/test-install.sh:ro" \
    "$BASE_IMAGE" \
    /bin/bash /test-install.sh \
    "$REPO_URL" \
    "$CODENAME" \
    "$REPO_NAME"
  
  exit 0
}

# Limit to first 5 packages for testing
PACKAGES=$(echo "$PACKAGES" | head -5)
PACKAGE_COUNT=$(echo "$PACKAGES" | wc -l)

echo "Found ${PACKAGE_COUNT} packages to test"
echo "$PACKAGES"
echo ""

# Test each package in a fresh container
SUCCESS_COUNT=0
FAIL_COUNT=0

for pkg in $PACKAGES; do
  echo "=========================================="
  echo "Testing package: $pkg in fresh container"
  echo "=========================================="
  
  if docker run --platform="$PLATFORM" --rm \
    -v "${SCRIPT_DIR}/test-installation.sh:/test-install.sh:ro" \
    "$BASE_IMAGE" \
    /bin/bash /test-install.sh \
    "$REPO_URL" \
    "$CODENAME" \
    "$REPO_NAME" \
    "$pkg"; then
    
    echo "✅ Package $pkg: SUCCESS"
    ((SUCCESS_COUNT++))
  else
    echo "❌ Package $pkg: FAILED"
    ((FAIL_COUNT++))
  fi
  
  echo ""
done

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total packages tested: $((SUCCESS_COUNT + FAIL_COUNT))"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
  exit 1
fi
