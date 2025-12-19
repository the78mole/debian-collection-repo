# Quick Start Guide

This guide will help you get started with the debian collection repository.

## Prerequisites

- GitHub account with repository access
- Repositories with `.deb` packages in their releases

## Setup Steps

### 1. Enable GitHub Pages

1. Go to your repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Save the changes

### 2. Configure Repositories to Monitor

Edit `repos.json` to list the repositories you want to collect packages from:

```json
{
  "repositories": [
    {
      "owner": "the78mole",
      "repo": "libcarla",
      "description": "CARLA library packages"
    }
  ]
}
```

See [REPOS_CONFIG.md](REPOS_CONFIG.md) for detailed configuration options.

### 3. Set Up GPG Signing (Optional but Recommended)

GPG signing ensures the authenticity of your packages:

1. **Generate a GPG key** (if you don't have one):
   ```bash
   gpg --full-generate-key
   ```
   - Choose RSA and RSA
   - Use at least 2048 bits (4096 recommended)
   - Set an expiration date (recommended)
   - Use your email address

2. **Find your key ID**:
   ```bash
   gpg --list-secret-keys --keyid-format LONG
   ```
   Look for the line like `sec   rsa4096/ABCD1234EF567890`
   The key ID is `ABCD1234EF567890`

3. **Export your private key**:
   ```bash
   gpg --armor --export-secret-keys ABCD1234EF567890
   ```
   Copy the entire output including the header and footer lines.

4. **Add to GitHub Secrets**:
   - Go to repository **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `GPG_PRIVATE_KEY`
   - Value: Paste the exported private key
   - Click **Add secret**

### 4. Run the Workflow

The workflow runs automatically:
- **Daily** at 2 AM UTC
- **When** you push changes to `repos.json` or the workflow file
- **Manually** from the Actions tab

To trigger manually:
1. Go to the **Actions** tab
2. Select **Build APT Repository**
3. Click **Run workflow**
4. Click the green **Run workflow** button

### 5. Use Your Repository

After the workflow completes (usually 2-5 minutes):

1. Visit your GitHub Pages URL: `https://<your-username>.github.io/<repository-name>`
2. Follow the instructions on that page to add the repository to your Debian/Ubuntu system

Example:
```bash
# Download and add the GPG key
curl -fsSL https://the78mole.github.io/debian-collection-repo/public.key | \
  sudo gpg --dearmor -o /usr/share/keyrings/debian-collection-repo.gpg

# Add the repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/debian-collection-repo.gpg] https://the78mole.github.io/debian-collection-repo stable main" | \
  sudo tee /etc/apt/sources.list.d/debian-collection-repo.list

# Update package lists
sudo apt update

# Install a package
sudo apt install <package-name>
```

## Troubleshooting

### Workflow Fails

1. Check the Actions tab for error messages
2. Verify repositories in `repos.json` exist and have releases
3. Ensure releases contain `.deb` files
4. Check that GITHUB_TOKEN has proper permissions

### No Packages Found

- Verify target repositories have releases with `.deb` attachments
- Check workflow logs for download errors
- Ensure repository names in `repos.json` are correct

### GPG Signing Issues

- Verify `GPG_PRIVATE_KEY` secret is set correctly
- Ensure the entire key (including headers) was copied
- Check workflow logs for GPG-specific errors
- Test your key locally: `echo "test" | gpg --clearsign`

### Pages Not Deploying

- Ensure GitHub Pages is enabled with "GitHub Actions" as source
- Check the Actions tab for deployment errors
- Verify the workflow completed successfully
- Wait a few minutes for Pages to update

## Next Steps

- Add more repositories to `repos.json`
- Set up a custom domain for GitHub Pages (optional)
- Configure scheduled updates to match your needs
- Share your repository URL with users

## Support

For issues or questions:
1. Check the [README.md](README.md) for detailed documentation
2. Review [REPOS_CONFIG.md](REPOS_CONFIG.md) for configuration options
3. Check workflow logs in the Actions tab
4. Open an issue in this repository
