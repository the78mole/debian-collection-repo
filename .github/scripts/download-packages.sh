#!/bin/bash
set -e

# Download packages from repositories listed in repos.json
# Usage: download-packages.sh <repos.json>

REPOS_JSON="${1:-repos.json}"
DOWNLOAD_DIR="downloads"

if [ ! -f "$REPOS_JSON" ]; then
    echo "Error: $REPOS_JSON not found"
    exit 1
fi

mkdir -p "$DOWNLOAD_DIR"

# Read repositories from config
repos=$(jq -c '.repositories[]' "$REPOS_JSON")

while IFS= read -r repo; do
    owner=$(echo "$repo" | jq -r '.owner')
    repo_name=$(echo "$repo" | jq -r '.repo')
    echo "Processing $owner/$repo_name"

    # Get latest release
    release_info=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$owner/$repo_name/releases/latest")

    if [ "$(echo "$release_info" | jq -r '.message')" = "Not Found" ]; then
        echo "No 'latest' release found for $owner/$repo_name, checking all releases..."
        all_releases=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/repos/$owner/$repo_name/releases")

        if [ "$(echo "$all_releases" | jq 'length')" = "0" ]; then
            echo "No releases found for $owner/$repo_name, skipping..."
            continue
        fi

        release_info=$(echo "$all_releases" | jq '.[0]')
    fi

    # Download all .deb files from the release
    echo "$release_info" | jq -r '.assets[]? | select(.name | endswith(".deb")) | "\(.browser_download_url)|\(.name)"' | while IFS='|' read url filename; do
        if [ -n "$url" ]; then
            echo "Downloading $filename from $url"
            curl -L -o "$DOWNLOAD_DIR/$filename" -H "Authorization: token $GITHUB_TOKEN" "$url"
        fi
    done
done <<< "$repos"

echo "Package download complete"
