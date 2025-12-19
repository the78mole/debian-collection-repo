#!/usr/bin/env python3
"""
Generate front page HTML from Jinja template
Usage: render-frontpage.py <apt-repo-dir> <output-file>
"""

import sys
import os
from datetime import datetime
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def count_packages(apt_repo_dir):
    """Count .deb files in all distribution pools"""
    pool_dir = Path(apt_repo_dir) / "pool"
    if not pool_dir.exists():
        return 0
    
    # Count all .deb files in all distribution pools
    total = 0
    for dist_dir in pool_dir.iterdir():
        if dist_dir.is_dir():
            main_dir = dist_dir / "main"
            if main_dir.exists():
                total += len(list(main_dir.glob("*.deb")))
    return total

def get_distribution_packages(apt_repo_dir):
    """Get package counts per distribution"""
    pool_dir = Path(apt_repo_dir) / "pool"
    distributions = {}
    
    if not pool_dir.exists():
        return distributions
    
    for dist_dir in sorted(pool_dir.iterdir()):
        if dist_dir.is_dir():
            main_dir = dist_dir / "main"
            if main_dir.exists():
                count = len(list(main_dir.glob("*.deb")))
                distributions[dist_dir.name] = count
    
    return distributions

def main():
    if len(sys.argv) < 3:
        print("Usage: render-frontpage.py <apt-repo-dir> <output-file>")
        sys.exit(1)
    
    apt_repo_dir = sys.argv[1]
    output_file = sys.argv[2]
    
    # Get environment variables
    repo_owner = os.environ.get('REPO_OWNER', 'unknown')
    repo_name = os.environ.get('REPO_NAME', 'debian-collection-repo')
    pages_url = f"https://{repo_owner}.github.io/{repo_name}"
    
    # Count packages
    package_count = count_packages(apt_repo_dir)
    distributions = get_distribution_packages(apt_repo_dir)
    
    # Get generated date
    generated_date = datetime.now(datetime.UTC).strftime('%Y-%m-%d %H:%M:%S UTC') if hasattr(datetime, 'UTC') else datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')
    
    # Setup Jinja environment
    template_dir = Path(__file__).parent.parent / "templates"
    env = Environment(loader=FileSystemLoader(str(template_dir)))
    template = env.get_template('frontpage.html.j2')
    
    # Render template
    html = template.render(
        repo_owner=repo_owner,
        repo_name=repo_name,
        pages_url=pages_url,
        package_count=package_count,
        distributions=distributions,
        generated_date=generated_date
    )
    
    # Write output
    with open(output_file, 'w') as f:
        f.write(html)
    
    print(f"Front page generated successfully: {output_file}")

if __name__ == '__main__':
    main()
