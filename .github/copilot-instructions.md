# GitHub Copilot Instructions for godot-web-template

## Project Overview

This is a **Godot 4.6 Web Template** repository that provides a complete CI/CD setup for exporting Godot projects to WebAssembly and deploying them to GitHub Pages. The template includes Docker-based build automation, service worker integration for SharedArrayBuffer support, and GitHub Actions workflows.

## Tech Stack

- **Game Engine**: Godot 4.6 (GL Compatibility rendering)
- **Export Target**: WebAssembly (Web)
- **CI/CD**: GitHub Actions
- **Container**: Docker (Ubuntu 22.04 base, Godot 4.6 headless)
- **Deployment**: GitHub Pages
- **Languages**: GDScript, Shell, Dockerfile, YAML

## Architecture

### Directory Structure

```
godot-web-template/
├── project/                # Godot 4.6 project root
│   ├── project.godot       # Project configuration
│   ├── export_presets.cfg  # Web export settings
│   ├── main.tscn           # Main scene
│   ├── main.gd             # Main script
│   └── icon.svg            # Project icon
├── docs/                   # GitHub Pages output (CI-managed)
├── ci/docker/              # Docker build configuration
│   ├── godot-4.6-headless.Dockerfile
│   └── build-image.sh      # Helper script
└── .github/
    ├── workflows/
    │   └── export-web.yml  # Main CI/CD pipeline
    └── prompts/            # Copilot prompt files
```

## Coding Conventions

### GDScript

- Follow [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- Use `snake_case` for variables and functions
- Use `PascalCase` for class names
- Always include type hints where possible
- Prefer `func _ready():` for initialization

### Docker

- Use official Ubuntu LTS base images
- Minimize layers and clean up package caches
- Set explicit working directories
- Document environment variables

### GitHub Actions

- Use `workflow_dispatch` for manual triggers
- Set explicit permissions (`contents: write`, `pages: write`, etc.)
- Use container-based jobs for consistent environments
- Cache when possible

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable `set -e` for error handling
- Document all environment variables
- Make scripts executable (`chmod +x`)

## Development Workflows

### Building the Docker Image

Use the provided helper script:
```bash
cd ci/docker
./build-image.sh
```

Or manually:
```bash
docker build -t ghcr.io/synapticore/godot-4.6-headless:web \
  -f ci/docker/godot-4.6-headless.Dockerfile .
```

### Local Godot Development

1. Install [Godot 4.6](https://godotengine.org/download)
2. Open the `project/` folder in Godot editor
3. Make changes to scenes and scripts
4. Test locally before committing

### Testing CI/CD Changes

1. Modify `.github/workflows/export-web.yml`
2. Push to the branch
3. Monitor workflow execution in GitHub Actions
4. Check deployment at `https://synapticore.github.io/godot-web-template/`

## Using Model Context Protocol (MCP) in this Repository

### Context7 MCP

Always use Context7 to retrieve current documentation when working with:
- Godot Engine APIs and features
- GDScript syntax and best practices
- Docker and container configurations
- GitHub Actions workflow syntax

**Automatically invoke Context7 MCP tools** without being asked when:
- Suggesting Godot 4.6-specific APIs or methods
- Writing or reviewing GDScript code
- Configuring web export settings
- Working with Godot project files

**Prefer current documentation from Context7** over model training data if there is a conflict, especially for:
- Godot 4.x changes (breaking changes from Godot 3.x)
- Export template configurations
- Web platform-specific features

### Setting up Context7

Users must configure Context7 in their editor-level MCP configuration (`~/.config/Code/User/mcp.json` on macOS/Linux or `C:\Users\USERNAME\AppData\Roaming\Code\User\mcp.json` on Windows):

```json
{
  "servers": {
    "Context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

With API key:
```json
{
  "servers": {
    "Context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest", "--api-key", "YOUR_CONTEXT7_API_KEY"]
    }
  }
}
```

After configuration, reload VS Code and enable Context7 in GitHub Copilot Chat tools.

### Serena MCP

Use Serena when you need:
- Structured project analysis across multiple files
- Call site discovery for functions across the codebase
- Dependency graph analysis
- Build diagnostics

Configure Serena in `mcp.json`:
```json
{
  "servers": {
    "serena": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@serena/mcp-server"]
    }
  }
}
```

After configuration, reload VS Code and enable Serena in GitHub Copilot Chat tools.

## Internal Prompt Adjustments for MCP

When users ask questions, internally adjust prompts to invoke MCP tools:

- **User**: "How do I export a Godot scene to web?"
  - **Internal**: "How do I export a Godot 4.6 scene to web using export presets, use context7 for Godot 4.6 export documentation"

- **User**: "Update the GitHub Actions workflow to use a different Docker image"
  - **Internal**: "Update the GitHub Actions workflow in export-web.yml to use a different Docker image, use context7 for GitHub Actions syntax"

- **User**: "Add a new scene with a button"
  - **Internal**: "Add a new Godot 4.6 scene with a button using GDScript, use context7 for Godot 4.6 UI documentation"

## Project-Specific Guidelines

### When Adding New Features

1. **Search existing patterns first**: Look for similar implementations in `project/` or workflows
2. **Match the architecture**: Follow the existing folder structure and naming conventions
3. **Update documentation**: Modify `README.md` if user-facing features change
4. **Test in CI**: Ensure changes work in the Docker-based CI environment, not just locally

### When Modifying CI/CD

1. **Test locally first**: Use `docker run` to test Docker changes before pushing
2. **Use workflow_dispatch**: Add manual triggers for testing
3. **Check permissions**: Ensure the workflow has required permissions (pages, contents, etc.)
4. **Validate YAML**: Use a YAML linter before committing

### When Working with Godot Projects

1. **Never edit `.godot/` or `.import` files**: These are generated by Godot
2. **Always commit `export_presets.cfg`**: Required for CI export
3. **Test exports locally**: Use Godot editor's export function before relying on CI
4. **Version compatibility**: This template is for Godot 4.6 - be careful with version-specific features

## Assumptions and Constraints

- This repository assumes users have Docker installed for building CI images
- GitHub Pages must be enabled with GitHub Actions as the source
- The Docker image must be built and pushed to GHCR before workflows can run
- Web export requires the "Web" export preset to exist in `export_presets.cfg`
- Service worker injection expects Godot to generate an `index.html` file

## Answering Style

When interacting with users of this repository:

- **Be precise and technical**: Assume users are experienced with Godot and CI/CD
- **Provide concrete examples**: Show actual code, commands, and file paths
- **Indicate assumptions**: If configuration is required, state it explicitly
- **Check MCP availability**: If Context7 or Serena are not configured, provide exact setup steps

## Documentation Updates

When suggesting improvements:

- **Add to README.md**: User-facing features, setup steps, troubleshooting
- **Add to CONTRIBUTING.md**: Developer workflows, testing procedures, code standards
- **Add to `.github/prompts/`**: Recurring workflows that could be automated
- **Update this file**: Changes to architecture, tech stack, or Copilot behavior

## Common Tasks

### Add a new Godot scene
```gdscript
# Create new scene file: project/new_scene.tscn
[gd_scene format=3]
[node name="NewScene" type="Control"]
```

### Add a new GDScript
```gdscript
extends Node

func _ready():
    print("Scene ready")
```

### Modify Docker image
```dockerfile
# Edit ci/docker/godot-4.6-headless.Dockerfile
# Then rebuild: ./ci/docker/build-image.sh
```

### Update workflow
```yaml
# Edit .github/workflows/export-web.yml
# Test with workflow_dispatch before merging
```

## References

- [Godot 4.6 Documentation](https://docs.godotengine.org/en/4.6/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
