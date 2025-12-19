#!/bin/bash
set -e

REPO_URL="$1"
CODENAME="$2"
REPO_NAME="$3"
PACKAGE_NAME="${4:-}"  # Optional: specific package to test

echo "=== Updating package lists ==="
apt-get update -qq

echo "=== Installing dependencies ==="
apt-get install -y -qq curl gnupg ca-certificates

echo "=== Adding repository key ==="
curl -fsSL "${REPO_URL}/public.key" -o /tmp/repo.key

# Prüfe ob GPG-Key vorhanden ist
if [ -s /tmp/repo.key ]; then
  gpg --dearmor < /tmp/repo.key > /usr/share/keyrings/${REPO_NAME}.gpg
  SIGNED_BY="signed-by=/usr/share/keyrings/${REPO_NAME}.gpg"
else
  echo "Warning: No GPG key found, repository is unsigned"
  SIGNED_BY=""
fi

echo "=== Adding repository to sources ==="
if [ -n "$SIGNED_BY" ]; then
  echo "deb [arch=$(dpkg --print-architecture) ${SIGNED_BY}] ${REPO_URL} ${CODENAME} main" > /etc/apt/sources.list.d/${REPO_NAME}.list
else
  echo "deb [arch=$(dpkg --print-architecture) trusted=yes] ${REPO_URL} ${CODENAME} main" > /etc/apt/sources.list.d/${REPO_NAME}.list
fi

cat /etc/apt/sources.list.d/${REPO_NAME}.list

echo "=== Updating package lists with new repository ==="
apt-get update -qq

if [ -n "$PACKAGE_NAME" ]; then
  # Test a specific package
  echo "=== Testing installation of: $PACKAGE_NAME ==="
  
  if ! apt-cache show "$PACKAGE_NAME" >/dev/null 2>&1; then
    echo "❌ Package $PACKAGE_NAME not available in repository"
    exit 1
  fi
  
  echo "📦 Installing $PACKAGE_NAME..."
  if apt-get install -y "$PACKAGE_NAME"; then
    echo "✅ Successfully installed $PACKAGE_NAME"
    
    echo ""
    echo "Package info:"
    dpkg -l | grep "$PACKAGE_NAME" || true
    
    echo ""
    echo "Installed files (first 20):"
    dpkg -L "$PACKAGE_NAME" | head -20 || true
    
    echo ""
    echo "Dependencies:"
    apt-cache depends "$PACKAGE_NAME" || true
    
    echo ""
    echo "✅ Package test completed successfully"
  else
    echo "❌ Failed to install $PACKAGE_NAME"
    echo "⚠️  This might indicate missing or incorrect dependencies!"
    exit 1
  fi
else
  # No specific package - just verify repository is accessible
  echo "=== Repository verification ==="
  ARCH=$(dpkg --print-architecture)
  PACKAGES_URL="${REPO_URL}/dists/${CODENAME}/main/binary-${ARCH}/Packages"
  
  if curl -fsSL "${PACKAGES_URL}" -o /tmp/packages.list 2>/dev/null; then
    PACKAGE_COUNT=$(grep -c '^Package: ' /tmp/packages.list || echo 0)
    echo "✅ Repository accessible, found ${PACKAGE_COUNT} packages"
  elif curl -fsSL "${PACKAGES_URL}.gz" >/dev/null 2>&1; then
    echo "✅ Repository accessible (gzipped Packages file)"
  else
    echo "⚠️  No Packages file found for ${CODENAME}/${ARCH}"
  fi
fi

echo "=== Test completed ==="
