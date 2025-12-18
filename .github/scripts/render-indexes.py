#!/usr/bin/env python3
"""
Generate directory index HTML files from Jinja template
Usage: render-indexes.py <apt-repo-dir>
"""

import sys
import os
from pathlib import Path
from datetime import datetime
from jinja2 import Environment, FileSystemLoader

def format_size(size):
    """Format file size in human-readable format"""
    if size < 1024:
        return f"{size}B"
    elif size < 1048576:
        return f"{size // 1024}K"
    else:
        return f"{size // 1048576}M"

def generate_index(template, directory, apt_repo_root):
    """Generate index.html for a directory"""
    # Calculate relative path from apt-repo root
    rel_path = directory.relative_to(apt_repo_root)
    rel_path_str = str(rel_path) if str(rel_path) != '.' else ''
    
    # Determine if we should show parent directory link
    show_parent = rel_path_str != ''
    
    # Get directories
    directories = []
    for item in sorted(directory.iterdir()):
        if item.is_dir():
            directories.append({'name': item.name})
    
    # Get files (excluding index.html)
    files = []
    for item in sorted(directory.iterdir()):
        if item.is_file() and item.name != 'index.html':
            stat = item.stat()
            size = format_size(stat.st_size)
            date = datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M')
            files.append({
                'name': item.name,
                'size': size,
                'date': date
            })
    
    # Render template
    html = template.render(
        relative_path=rel_path_str or '/',
        show_parent=show_parent,
        directories=directories,
        files=files
    )
    
    # Write index.html
    index_file = directory / 'index.html'
    with open(index_file, 'w') as f:
        f.write(html)

def main():
    if len(sys.argv) < 2:
        print("Usage: render-indexes.py <apt-repo-dir>")
        sys.exit(1)
    
    apt_repo_dir = Path(sys.argv[1])
    
    if not apt_repo_dir.exists():
        print(f"Error: APT repository directory {apt_repo_dir} not found")
        sys.exit(1)
    
    # Setup Jinja environment
    template_dir = Path(__file__).parent.parent / "templates"
    env = Environment(loader=FileSystemLoader(str(template_dir)))
    template = env.get_template('directory-index.html.j2')
    
    print("Generating directory indexes...")
    
    # Generate index for each directory except the root
    for directory in apt_repo_dir.rglob('*'):
        if directory.is_dir() and directory != apt_repo_dir:
            generate_index(template, directory, apt_repo_dir)
    
    print("Directory indexes generated successfully")

if __name__ == '__main__':
    main()
