#!/usr/bin/env python3
"""
Generate GitHub Actions matrix configuration from distros.yaml
Usage: python3 generate-matrix.py
"""

import json
import sys
from pathlib import Path
try:
    import yaml
except ImportError:
    print("Error: PyYAML not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pyyaml'])
    import yaml

def main():
    # Read distros.yaml
    config_file = Path(__file__).parent.parent.parent / "distros.yaml"
    
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)
    
    # Generate matrix include list
    matrix_include = []
    
    for dist in config['distributions']:
        # Each distribution has its own architectures
        for arch in dist['architectures']:
            matrix_include.append({
                'distro': dist['distro'],
                'version': dist['version'],
                'codename': dist['codename'],
                'arch': arch,
                'display_name': dist['display_name']
            })
    
    # Output as GitHub Actions matrix JSON
    output = {
        'include': matrix_include
    }
    
    print(json.dumps(output))

if __name__ == '__main__':
    main()
