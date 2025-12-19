#!/bin/bash
# Generate distributions list from distros.yaml
# Usage: source load-distros.sh
# Sets: DISTRIBUTIONS, ARCHITECTURES arrays

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../../distros.yaml"

# Install yq if not present
if ! command -v yq &> /dev/null; then
    echo "yq not found, using Python to parse YAML"
    
    # Use Python as fallback
    read_yaml_python() {
        python3 -c "
import yaml
import sys
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
    if sys.argv[1] == 'distributions':
        print(' '.join([d['codename'] for d in config['distributions']]))
    elif sys.argv[1] == 'architectures':
        # Get unique architectures across all distributions
        archs = set()
        for d in config['distributions']:
            archs.update(d['architectures'])
        print(' '.join(sorted(archs)))
    elif sys.argv[1] == 'components':
        print(' '.join(config['components']))
" "$1"
    }
    
    DISTRIBUTIONS=$(read_yaml_python distributions)
    ARCHITECTURES=$(read_yaml_python architectures)
    COMPONENTS=$(read_yaml_python components)
else
    # Use yq if available
    DISTRIBUTIONS=$(yq eval '.distributions[].codename' "$CONFIG_FILE" | tr '\n' ' ')
    # Get unique architectures across all distributions
    ARCHITECTURES=$(yq eval '.distributions[].architectures[]' "$CONFIG_FILE" | sort -u | tr '\n' ' ')
    COMPONENTS=$(yq eval '.components[]' "$CONFIG_FILE" | tr '\n' ' ')
fi

export DISTRIBUTIONS
export ARCHITECTURES
export COMPONENTS

# Function to get display name for a codename
get_display_name() {
    local codename="$1"
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
    for d in config['distributions']:
        if d['codename'] == '$codename':
            print(d['display_name'])
            break
"
}
export -f get_display_name

# Function to get distro type (ubuntu/debian) for a codename
get_distro_type() {
    local codename="$1"
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
    for d in config['distributions']:
        if d['codename'] == '$codename':
            print(d['distro'])
            break
"
}
export -f get_distro_type

# Function to get version for a codename
get_distro_version() {
    local codename="$1"
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
    for d in config['distributions']:
        if d['codename'] == '$codename':
            print(d['version'])
            break
"
}
export -f get_distro_version

# Function to get architectures for a codename
get_architectures() {
    local codename="$1"
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
    for d in config['distributions']:
        if d['codename'] == '$codename':
            print(' '.join(d['architectures']))
            break
"
}
export -f get_architectures
