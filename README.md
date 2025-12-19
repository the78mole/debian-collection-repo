# Debian Collection Repository

[![Repository](https://img.shields.io/badge/📦_APT_Repository-View_Packages-blue?style=for-the-badge)](https://the78mole.github.io/debian-collection-repo/)
[![GitHub Pages](https://github.com/the78mole/debian-collection-repo/actions/workflows/build-repo.yml/badge.svg)](https://github.com/the78mole/debian-collection-repo/actions/workflows/build-repo.yml)

This repository automatically collects Debian packages from multiple GitHub repositories and publishes them as a unified APT repository via GitHub Pages.

## Quick Start

New to this repository? Check out the [Quick Start Guide](QUICKSTART.md) for step-by-step setup instructions.

## Features

- 🔄 Automatic collection of `.deb` packages from multiple GitHub repositories
- 🔐 GPG signing of packages for secure distribution
- 📦 Standard APT repository structure with proper metadata
- 🚀 Automated deployment to GitHub Pages
- ⏰ Scheduled daily updates
- 🔧 Easy configuration via JSON file

## How It Works

1. The workflow reads repository configurations from `repos.json`
2. Downloads the latest `.deb` packages from each repository's releases
3. Signs packages with GPG key (if configured)
4. Generates APT repository metadata (Packages, Release files)
5. Deploys to GitHub Pages

## Configuration

### Adding Repositories

Edit `repos.json` to add repositories to collect packages from:

```json
{
  "repositories": [
    {
      "owner": "the78mole",
      "repo": "libcarla",
      "description": "CARLA library packages"
    },
    {
      "owner": "username",
      "repo": "another-repo",
      "description": "Description of the packages"
    }
  ]
}
```

See [REPOS_CONFIG.md](REPOS_CONFIG.md) for detailed configuration options.

### Configuring Distributions and Architectures

Edit `distros.yaml` to configure which distributions and architectures to support:

```yaml
distributions:
  - distro: ubuntu
    version: "22.04"
    codename: jammy
    display_name: "Ubuntu 22.04 LTS (Jammy Jellyfish)"
    architectures: [amd64, arm64]
    matches: [ubuntu22.04, ubuntu-22.04, jammy]
    eol: "2027-04"
  
  - distro: debian
    version: "12"
    codename: bookworm
    display_name: "Debian 12 (Bookworm)"
    architectures: [amd64, arm64, armhf]
    matches: [debian12, debian-12, bookworm]
    eol: "2026-06"

components:
  - main
```

Each distribution can define its own supported architectures. See [DISTROS_CONFIG.md](DISTROS_CONFIG.md) for detailed configuration options.

This configuration is used by:
- Repository build workflow (directory structure)
- Package installation tests (test matrix)
- Front-end generation (documentation)

### Setting Up GPG Signing

1. Generate a GPG key (if you don't have one):
   ```bash
   gpg --full-generate-key
   ```

2. Export your private key:
   ```bash
   gpg --armor --export-secret-keys YOUR_KEY_ID
   ```

3. Add the private key as a repository secret:
   - Go to repository Settings → Secrets and variables → Actions
   - Create a new secret named `GPG_PRIVATE_KEY`
   - Paste your private key (including `-----BEGIN PGP PRIVATE KEY BLOCK-----` and `-----END PGP PRIVATE KEY BLOCK-----`)

### Enabling GitHub Pages

GitHub Pages will be automatically configured when you first run the workflow. After the workflow completes successfully:

1. Go to repository Settings → Pages
2. Verify that the source is set to "GitHub Actions"
3. Your repository will be published at `https://<your-username>.github.io/<repository-name>`

**Note:** If this is your first deployment, GitHub Pages will be automatically enabled. You don't need to manually configure anything - just run the workflow!

## Using the Repository

### On Debian/Ubuntu Systems

After the workflow completes, visit your GitHub Pages URL (e.g., `https://the78mole.github.io/debian-collection-repo`) for specific instructions tailored to your repository.

General template:

```bash
# Download and add the GPG key
curl -fsSL https://<your-username>.github.io/<repository-name>/public.key | sudo gpg --dearmor -o /usr/share/keyrings/<repository-name>.gpg

# Add the repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/<repository-name>.gpg] https://<your-username>.github.io/<repository-name> stable main" | sudo tee /etc/apt/sources.list.d/<repository-name>.list

# Update package lists
sudo apt update

# Install packages
sudo apt install <package-name>
```

### Manual Trigger

The workflow can be manually triggered from the Actions tab:
1. Go to Actions → Build APT Repository
2. Click "Run workflow"

## Repository Structure

```
apt-repo/
├── dists/
│   ├── jammy/                    # Ubuntu 22.04 LTS
│   │   ├── Release               # Repository metadata
│   │   ├── Release.gpg          # GPG signature
│   │   ├── InRelease            # Signed Release file
│   │   └── main/
│   │       ├── binary-amd64/
│   │       │   ├── Packages     # Package index (amd64)
│   │       │   ├── Packages.gz  # Compressed index
│   │       │   └── index.html   # Directory listing
│   │       └── binary-arm64/
│   │           ├── Packages     # Package index (arm64)
│   │           ├── Packages.gz  # Compressed index
│   │           └── index.html   # Directory listing
│   ├── noble/                    # Ubuntu 24.04 LTS
│   │   ├── Release               # Repository metadata
│   │   ├── Release.gpg          # GPG signature
│   │   ├── InRelease            # Signed Release file
│   │   └── main/
│   │       ├── binary-amd64/
│   │       │   ├── Packages     # Package index (amd64)
│   │       │   ├── Packages.gz  # Compressed index
│   │       │   └── index.html   # Directory listing
│   │       └── binary-arm64/
│   │           ├── Packages     # Package index (arm64)
│   │           ├── Packages.gz  # Compressed index
│   │           └── index.html   # Directory listing
│   ├── bookworm/                 # Debian 12
│   │   ├── Release               # Repository metadata
│   │   ├── Release.gpg          # GPG signature
│   │   ├── InRelease            # Signed Release file
│   │   └── main/
│   │       ├── binary-amd64/
│   │       │   ├── Packages     # Package index (amd64)
│   │       │   ├── Packages.gz  # Compressed index
│   │       │   └── index.html   # Directory listing
│   │       └── binary-arm64/
│   │           ├── Packages     # Package index (arm64)
│   │           ├── Packages.gz  # Compressed index
│   │           └── index.html   # Directory listing
│   └── trixie/                   # Debian 13
│       ├── Release               # Repository metadata
│       ├── Release.gpg          # GPG signature
│       ├── InRelease            # Signed Release file
│       └── main/
│           ├── binary-amd64/
│           │   ├── Packages     # Package index (amd64)
│           │   ├── Packages.gz  # Compressed index
│           │   └── index.html   # Directory listing
│           └── binary-arm64/
│               ├── Packages     # Package index (arm64)
│               ├── Packages.gz  # Compressed index
│               └── index.html   # Directory listing
├── pool/
│   └── main/
│       ├── *_amd64.deb          # amd64 packages
│       ├── *_arm64.deb          # arm64 packages
│       ├── *_all.deb            # Architecture-independent packages
│       └── index.html           # Directory listing
├── public.key                   # GPG public key
└── index.html                   # Repository homepage
```

Each directory includes an `index.html` file for easy browsing of the repository structure.

## Workflow Architecture

The workflow is modular and uses separate scripts for maintainability:

### Scripts (`.github/scripts/`)

- **`download-packages.sh`** - Downloads `.deb` files from GitHub releases
- **`generate-metadata.sh`** - Creates APT repository metadata (Packages, Release)
- **`sign-release.sh`** - Signs Release file with GPG key
- **`generate-frontpage.sh`** - Creates enhanced HTML front page with usage info
- **`generate-indexes.sh`** - Generates directory index files for all folders
- **`render-frontpage.py`** - Python script to render front page from Jinja template
- **`render-indexes.py`** - Python script to render directory indexes from Jinja template

### Templates (`.github/templates/`)

HTML generation uses Jinja2 templates for better maintainability and separation of concerns:

- **`frontpage.html.j2`** - Template for the repository homepage
- **`directory-index.html.j2`** - Template for directory listings

Templates accept dynamic inputs like repository name, package count, and URLs, making them easy to customize without modifying code.

This modular approach keeps the workflow clean (94 lines vs 210+ lines of inline code) and makes scripts reusable and testable.

## Workflow Schedule

- **Automatic**: Runs daily at 2 AM UTC
- **Manual**: Can be triggered via Actions tab
- **On Push**: Runs when `repos.json` or workflow file is updated

## Troubleshooting

### No packages found
- Ensure repositories have releases with `.deb` files
- Check that repository names in `repos.json` are correct
- Verify GITHUB_TOKEN has access to the repositories

### GPG signing fails
- Ensure GPG_PRIVATE_KEY secret is set correctly
- Verify the key format includes headers and footers
- Check workflow logs for specific GPG errors

## License

See [LICENSE](LICENSE) file for details.
