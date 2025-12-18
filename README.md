# Debian Collection Repository

This repository automatically collects Debian packages from multiple GitHub repositories and publishes them as a unified APT repository via GitHub Pages.

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

1. Go to repository Settings → Pages
2. Under "Source", select "GitHub Actions"
3. The repository will be published at `https://the78mole.github.io/debian-collection-repo`

## Using the Repository

### On Debian/Ubuntu Systems

```bash
# Download and add the GPG key
curl -fsSL https://the78mole.github.io/debian-collection-repo/public.key | sudo gpg --dearmor -o /usr/share/keyrings/debian-collection-repo.gpg

# Add the repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/debian-collection-repo.gpg] https://the78mole.github.io/debian-collection-repo stable main" | sudo tee /etc/apt/sources.list.d/debian-collection-repo.list

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
│   └── stable/
│       ├── Release          # Repository metadata
│       ├── Release.gpg      # GPG signature
│       ├── InRelease        # Signed Release file
│       └── main/
│           └── binary-amd64/
│               ├── Packages    # Package index
│               └── Packages.gz # Compressed index
├── pool/
│   └── main/               # Actual .deb packages
├── public.key              # GPG public key
└── index.html             # Repository homepage
```

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
