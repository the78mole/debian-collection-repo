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

# Run test in container
docker run --platform="$PLATFORM" --rm \
  -v "${SCRIPT_DIR}/test-installation.sh:/test-install.sh:ro" \
  "$BASE_IMAGE" \
  /bin/bash /test-install.sh \
  "$REPO_URL" \
  "$CODENAME" \
  "$REPO_NAME"
