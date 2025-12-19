# Distribution Configuration

This file (`distros.yaml`) defines all supported Linux distributions and their architectures for the APT repository.

## Structure

```yaml
distributions:
  - distro: ubuntu              # Distribution type (ubuntu/debian)
    version: "22.04"            # Version number
    codename: jammy             # Distribution codename
    display_name: "Ubuntu 22.04 LTS (Jammy Jellyfish)"  # Human-readable name
    architectures: [amd64, arm64]  # Supported architectures
    matches: [ubuntu22.04, ubuntu-22.04, jammy]  # Alternative package names
    eol: "2027-04"             # End-of-life date (YYYY-MM)

components:
  - main                        # APT components (main, contrib, non-free)
```

## Fields

### Required Fields

- **distro**: Type of distribution (`ubuntu` or `debian`)
- **version**: Official version number (e.g., `"22.04"`, `"12"`)
- **codename**: Official codename (e.g., `jammy`, `bookworm`)
  - Used in repository paths: `dists/jammy/`, `pool/jammy/`
- **display_name**: Human-readable name for documentation
- **architectures**: Array of supported CPU architectures
  - Common: `amd64`, `arm64`, `armhf`, `i386`
  - Each distribution can have different architectures

### Optional Fields

- **matches**: Array of alternative distribution identifiers
  - Used for flexible package matching
  - Examples: `ubuntu22.04`, `ubuntu-22.04`, `jammy`
- **eol**: End-of-life date in `YYYY-MM` format
  - Helps track distribution support lifecycle

## Usage

This configuration is automatically used by:

1. **Build Workflow** ([.github/workflows/build-repo.yml](.github/workflows/build-repo.yml))
   - Creates directory structure for each distribution
   - Generates metadata for each architecture
   
2. **Test Workflow** ([.github/workflows/test-packages.yml](.github/workflows/test-packages.yml))
   - Generates test matrix for all distribution/architecture combinations
   - Tests package installation in Docker containers

3. **Frontend Generation** ([.github/scripts/render-frontpage.py](.github/scripts/render-frontpage.py))
   - Generates installation instructions
   - Creates distribution-specific documentation

4. **Helper Scripts** ([.github/scripts/load-distros.sh](.github/scripts/load-distros.sh))
   - Provides functions to query configuration
   - Exports environment variables

## Adding a New Distribution

To add support for a new distribution:

1. Add an entry to the `distributions` array in `distros.yaml`
2. Commit and push the changes
3. The workflows will automatically:
   - Create the necessary directory structure
   - Add the distribution to the test matrix
   - Update the documentation

Example:

```yaml
distributions:
  - distro: ubuntu
    version: "26.04"
    codename: plucky
    display_name: "Ubuntu 26.04 LTS"
    architectures: [amd64, arm64]
    matches: [ubuntu26.04, ubuntu-26.04, plucky]
    eol: "2031-04"
```

## Architecture Support

Each distribution can define its own supported architectures. This allows flexibility for:

- Older distributions that don't support ARM64
- Specialized distributions with unique architecture requirements
- Gradual migration of architecture support

Example with different architectures:

```yaml
distributions:
  - distro: debian
    codename: buster
    architectures: [amd64, i386, armhf]  # No arm64 support
  
  - distro: debian
    codename: bookworm
    architectures: [amd64, arm64, armhf, i386]  # Full support
```

## Validation

The configuration is validated automatically during workflow runs. Ensure:

- All required fields are present
- Architecture names are valid Debian architecture names
- Codenames are unique
- YAML syntax is correct

Test locally with:

```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('distros.yaml'))"

# Test matrix generation
python3 .github/scripts/generate-matrix.py
```
