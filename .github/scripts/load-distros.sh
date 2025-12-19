#!/bin/bash
# Generate distributions list from distros.yaml
# Usage: source load-distros.sh
# Sets: DISTRIBUTIONS, ARCHITECTURES, COMPONENTS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../../distros.yaml"

# Ensure PyYAML is installed
if ! python3 -c "import yaml" 2>/dev/null; then
    echo "Installing PyYAML..." >&2
    python3 -m pip install --user pyyaml >&2
fi

# Use Python to parse YAML (more reliable than yq)
read_yaml_python() {
    python3 << EOF
import yaml
import sys

try:
    with open('$CONFIG_FILE', 'r') as f:
        config = yaml.safe_load(f)
        
    if '$1' == 'distributions':
        print(' '.join([d['codename'] for d in config['distributions']]))
    elif '$1' == 'architectures':
        # Get unique architectures across all distributions
        archs = set()
        for d in config['distributions']:
            archs.update(d.get('architectures', []))
        print(' '.join(sorted(archs)))
    elif '$1' == 'components':
        print(' '.join(config.get('components', ['main'])))
except Exception as e:
    print(f"Error reading config: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

DISTRIBUTIONS=$(read_yaml_python distributions)
ARCHITECTURES=$(read_yaml_python architectures)
COMPONENTS=$(read_yaml_python components)

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
