# Contributing to Godot Web Template

Thank you for your interest in contributing to the Godot 4.6 Web Template! This guide will help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Using GitHub Copilot](#using-github-copilot)

## Code of Conduct

This project follows GitHub's Community Guidelines. Please be respectful, inclusive, and constructive in all interactions.

## Getting Started

### Prerequisites

- **Godot 4.6**: Download from [godotengine.org](https://godotengine.org/download)
- **Docker**: Required for building CI images (optional for Godot-only contributions)
- **Git**: For version control
- **Code Editor**: VS Code with Godot extension recommended

### First Steps

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/godot-web-template.git
   cd godot-web-template
   ```

2. **Explore the structure**
   - Read `README.md` for project overview
   - Review `.github/copilot-instructions.md` for architecture details
   - Check existing issues and PRs

3. **Open the Godot project**
   ```bash
   # Open the project/ folder in Godot 4.6
   godot project/project.godot
   ```

4. **Run the sample**
   - Press F5 in Godot to run the project
   - Verify the sample scene loads and works

## Development Setup

### For Godot Development

1. Install Godot 4.6
2. Open `project/` folder in Godot editor
3. Make changes to scenes or scripts
4. Test with F5 or export to web

### For CI/CD Development

1. Install Docker Desktop
2. Build the Docker image:
   ```bash
   cd ci/docker
   ./build-image.sh
   ```
3. Test the image locally:
   ```bash
   docker run --rm -v $(pwd):/project \
     ghcr.io/USERNAME/godot-4.6-headless:web \
     --path /project/project --export-release "Web" /project/build/index.html
   ```

### For Workflow Development

1. Make changes to `.github/workflows/export-web.yml`
2. Push to a feature branch
3. Monitor the workflow run in GitHub Actions
4. Iterate based on results

## How to Contribute

### Types of Contributions

We welcome:

- **Bug fixes**: Fix issues in the Godot project, workflows, or Docker setup
- **Documentation**: Improve README, add guides, clarify instructions
- **Features**: Add new scenes, scripts, or CI/CD enhancements
- **Examples**: Add example game mechanics or export configurations
- **Optimization**: Improve build times, reduce image size, optimize exports

### Finding Issues

- Look for issues labeled `good first issue` for beginner-friendly tasks
- Check `help wanted` for tasks that need contributors
- Propose new features by opening an issue first

### Creating an Issue

When reporting bugs:
- Describe what you expected to happen
- Describe what actually happened
- Include steps to reproduce
- Mention your environment (OS, Godot version, Docker version)

When proposing features:
- Explain the use case
- Describe the proposed solution
- Consider alternatives
- Be open to discussion

## Coding Standards

### GDScript

Follow the [Godot GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

```gdscript
# Good
extends Node

var player_health: int = 100
const MAX_SPEED: float = 200.0

func _ready() -> void:
    print("Node ready")

func take_damage(amount: int) -> void:
    player_health -= amount
    if player_health <= 0:
        _die()

func _die() -> void:
    queue_free()
```

Key points:
- Use `snake_case` for variables and functions
- Use `PascalCase` for class names
- Use `UPPER_SNAKE_CASE` for constants
- Always include type hints
- Private functions start with `_`

### Shell Scripts

```bash
#!/bin/bash
set -e  # Exit on error

# Use descriptive variable names
IMAGE_NAME="godot-4.6-headless"
TAG="web"

# Document what the script does
echo "Building Docker image: ${IMAGE_NAME}:${TAG}"

# Check prerequisites
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi
```

### Dockerfile

```dockerfile
# Use specific versions
FROM ubuntu:22.04

# Group related commands
RUN apt-get update && \
    apt-get install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Document environment variables
ENV GODOT_BIN=/usr/local/bin/Godot_v4.6-stable_linux.x86_64

# Set working directory
WORKDIR /project
```

### GitHub Actions

```yaml
# Use clear job names
jobs:
  export-and-deploy:
    runs-on: ubuntu-latest
    
    # Set explicit permissions
    permissions:
      contents: write
      pages: write
    
    # Document each step
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Export web build
        run: |
          # Clear description of what this does
          mkdir -p build/web
```

## Testing Guidelines

### Testing Godot Changes

1. **Local testing**
   - Run in Godot editor (F5)
   - Test all modified scenes
   - Check console for errors

2. **Web export testing**
   - Export to web from Godot
   - Open in browser
   - Test in Chrome, Firefox, and Safari
   - Check browser console for errors

3. **Verify export presets**
   - Ensure `export_presets.cfg` is committed
   - Verify "Web" preset exists and is configured

### Testing CI/CD Changes

1. **Docker image testing**
   ```bash
   # Build locally
   docker build -t test-godot -f ci/docker/godot-4.6-headless.Dockerfile .
   
   # Test export
   docker run --rm -v $(pwd):/work -w /work test-godot \
     --path ./project --export-release "Web" ./build/index.html
   ```

2. **Workflow testing**
   - Push to a feature branch
   - Enable workflow_dispatch if needed
   - Monitor GitHub Actions tab
   - Check workflow logs for errors

3. **Deployment testing**
   - Verify GitHub Pages deployment
   - Check that the site loads
   - Test service worker headers in browser DevTools

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass (if applicable)
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No merge conflicts with main

## Pull Request Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes

- Keep commits focused and atomic
- Write clear commit messages:
  ```
  Add button interaction to sample scene
  
  - Created new button in main.tscn
  - Added click handler in main.gd
  - Updated README with new feature
  ```

### 3. Test Thoroughly

- Test locally in Godot
- Export to web and verify
- If modifying CI/CD, test the workflow

### 4. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then on GitHub:
- Click "New Pull Request"
- Fill out the PR template
- Link related issues
- Add screenshots if UI changed

### 5. PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] CI/CD improvement

## Testing
- [ ] Tested in Godot editor
- [ ] Tested web export
- [ ] Tested CI/CD workflow

## Screenshots (if applicable)
[Add screenshots here]

## Related Issues
Closes #123
```

### 6. Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Once approved, a maintainer will merge

## Using GitHub Copilot

This repository includes Copilot agent instructions to help you contribute more effectively.

### Setup GitHub Copilot with MCP

For the best experience, configure Context7 MCP to get up-to-date Godot documentation:

1. **Edit your MCP config** (`~/.config/Code/User/mcp.json`):
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

2. **Reload VS Code**

3. **Enable Context7** in Copilot Chat (Tools icon)

### Using Copilot Prompts

Generate an onboarding plan:
```
@workspace /onboarding-plan I'm new to Godot but experienced with Docker
```

Ask about architecture:
```
@workspace How does the CI/CD pipeline work?
```

Get code suggestions:
```
@workspace Add a new scene with a sprite and movement controls
```

### Copilot Best Practices

- Read `.github/copilot-instructions.md` to understand how Copilot is configured
- Use `@workspace` to include repository context
- Ask specific questions about Godot 4.6 features
- Request code reviews from Copilot before submitting

## Questions?

- Open an issue for bugs or feature requests
- Use GitHub Discussions for questions
- Check existing issues and PRs first

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- README acknowledgments (for major features)

Thank you for contributing to make this template better for everyone!
