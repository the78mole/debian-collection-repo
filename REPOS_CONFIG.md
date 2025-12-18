# Repository Configuration

This file (`repos.json`) defines which GitHub repositories to collect Debian packages from.

## Format

```json
{
  "repositories": [
    {
      "owner": "github-username",
      "repo": "repository-name",
      "description": "Optional description"
    }
  ]
}
```

## Fields

- **owner** (required): GitHub username or organization that owns the repository
- **repo** (required): Name of the repository
- **description** (optional): Human-readable description of the packages from this repository

## How It Works

The workflow will:
1. Check the latest release from each repository
2. Download all `.deb` files attached to that release
3. Add them to the APT repository pool

## Example

```json
{
  "repositories": [
    {
      "owner": "the78mole",
      "repo": "libcarla",
      "description": "CARLA library packages"
    },
    {
      "owner": "your-username",
      "repo": "another-package",
      "description": "Another set of packages"
    }
  ]
}
```

## Notes

- Repositories must have at least one release with `.deb` files attached
- The workflow runs daily to check for new releases
- You can manually trigger the workflow from the Actions tab after modifying this file
