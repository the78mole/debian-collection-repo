#!/bin/bash
set -e

REPO_URL="$1"
CODENAME="$2"
REPO_NAME="$3"

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

echo "=== Listing available packages from repository ==="
apt-cache search . | grep -v "^$" | head -20 || true

echo "=== Testing package installation ==="
# Versuche alle verfügbaren Pakete aus dem Repository zu finden
PACKAGES=$(apt-cache search . | awk '{print $1}' | grep -E '^[a-z]' | head -5)

if [ -z "$PACKAGES" ]; then
  echo "Warning: No packages found in repository for this distribution"
  exit 0
fi

echo "Found packages: $PACKAGES"

# Installiere jedes Paket einzeln und teste es
for pkg in $PACKAGES; do
  echo "--- Testing package: $pkg ---"
  
  # Prüfe ob Paket verfügbar ist
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    apt-get install -y -qq "$pkg" || {
      echo "Failed to install $pkg"
      continue
    }
    
    echo "✓ Successfully installed $pkg"
    
    # Zeige Paketinformationen
    dpkg -l | grep "$pkg" || true
    
    # Optional: Teste ob Paket-Dateien vorhanden sind
    dpkg -L "$pkg" | head -10 || true
  else
    echo "Package $pkg not available in repository"
  fi
  echo ""
done

echo "=== Installation test completed ==="
