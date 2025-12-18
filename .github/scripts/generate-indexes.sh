#!/bin/bash
set -e

# Generate directory index files for all folders in apt-repo
# Usage: generate-indexes.sh <apt-repo-dir>

APT_REPO="${1:-apt-repo}"

if [ ! -d "$APT_REPO" ]; then
    echo "Error: APT repository directory $APT_REPO not found"
    exit 1
fi

generate_index() {
    local dir="$1"
    local rel_path="${dir#$APT_REPO}"
    rel_path="${rel_path#/}"
    
    if [ -z "$rel_path" ]; then
        # Root directory - use main index
        return
    fi
    
    local parent_path=""
    if [ "$rel_path" != "." ]; then
        parent_path=$(dirname "$rel_path")
        if [ "$parent_path" = "." ]; then
            parent_path=""
        fi
    fi
    
    cat > "$dir/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Index of /$rel_path</title>
    <style>
        body { font-family: monospace; margin: 20px; }
        h1 { font-size: 18px; }
        table { border-collapse: collapse; width: 100%; }
        th { text-align: left; padding: 8px; background-color: #f0f0f0; }
        td { padding: 8px; }
        tr:hover { background-color: #f5f5f5; }
        a { text-decoration: none; color: #0066cc; }
        a:hover { text-decoration: underline; }
        .size { text-align: right; }
        .date { white-space: nowrap; }
    </style>
</head>
<body>
    <h1>Index of /$rel_path</h1>
    <table>
        <tr>
            <th>Name</th>
            <th class="size">Size</th>
            <th class="date">Last Modified</th>
        </tr>
EOF

    # Add parent directory link if not in root
    if [ -n "$parent_path" ]; then
        echo "        <tr><td><a href=\"../\">../</a></td><td class=\"size\">-</td><td class=\"date\">-</td></tr>" >> "$dir/index.html"
    elif [ "$rel_path" != "." ]; then
        echo "        <tr><td><a href=\"../\">../</a></td><td class=\"size\">-</td><td class=\"date\">-</td></tr>" >> "$dir/index.html"
    fi
    
    # List directories first
    find "$dir" -maxdepth 1 -type d ! -path "$dir" -printf "%f\n" | sort | while read item; do
        echo "        <tr><td><a href=\"$item/\">$item/</a></td><td class=\"size\">-</td><td class=\"date\">-</td></tr>" >> "$dir/index.html"
    done
    
    # List files
    find "$dir" -maxdepth 1 -type f ! -name "index.html" -printf "%f\t%s\t%TY-%Tm-%Td %TH:%TM\n" | sort | while IFS=$'\t' read name size date; do
        # Format size
        if [ "$size" -lt 1024 ]; then
            size_fmt="${size}B"
        elif [ "$size" -lt 1048576 ]; then
            size_fmt="$(( size / 1024 ))K"
        else
            size_fmt="$(( size / 1048576 ))M"
        fi
        echo "        <tr><td><a href=\"$name\">$name</a></td><td class=\"size\">$size_fmt</td><td class=\"date\">$date</td></tr>" >> "$dir/index.html"
    done
    
    cat >> "$dir/index.html" <<EOF
    </table>
</body>
</html>
EOF
}

echo "Generating directory indexes..."

# Generate index for each directory in apt-repo
find "$APT_REPO" -type d | while read dir; do
    # Skip the root apt-repo directory (it has a custom index.html)
    if [ "$dir" != "$APT_REPO" ]; then
        generate_index "$dir"
    fi
done

echo "Directory indexes generated successfully"
