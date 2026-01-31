---
mode: 'agent'
description: 'Guide for adding new features to the Godot Web Template project'
---

# Feature Development Guide

You are helping a contributor add a new feature to the **Godot 4.6 Web Template** repository. Provide step-by-step guidance based on the type of feature they want to add.

## Before Starting

1. **Check if the feature already exists**
   - Search the codebase for similar implementations
   - Check open and closed issues
   - Review existing PRs

2. **Verify it fits the project scope**
   - Is it related to Godot web export?
   - Does it enhance the CI/CD pipeline?
   - Will it benefit other users of the template?

3. **Create an issue first** (for major features)
   - Describe the feature and use case
   - Get feedback from maintainers
   - Discuss implementation approach

## Feature Type: Godot Game Feature

When adding game mechanics, scenes, or GDScript functionality:

### Steps

1. **Create the feature in Godot editor**
   ```bash
   # Open the project
   godot project/project.godot
   ```

2. **Add new scene file**
   - Create scene in `project/` directory
   - Use descriptive names (e.g., `player.tscn`, `menu.tscn`)
   - Follow scene hierarchy conventions

3. **Create corresponding script**
   ```gdscript
   extends Node  # or appropriate parent class
   
   # Export variables for editor configuration
   @export var speed: float = 100.0
   
   # Private variables
   var _velocity: Vector2 = Vector2.ZERO
   
   func _ready() -> void:
       # Initialize
       pass
   
   func _process(delta: float) -> void:
       # Update logic
       pass
   ```

4. **Test in editor**
   - Run the scene (F6) or project (F5)
   - Verify functionality
   - Check console for errors

5. **Test web export**
   - Export to web using Project > Export
   - Open in browser
   - Verify it works in web environment

6. **Update documentation**
   - Add feature description to README.md
   - Document any new controls or mechanics
   - Include screenshots if helpful

### Example: Adding a Player Controller

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta: float) -> void:
    var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_vector * speed
    move_and_slide()
```

## Feature Type: CI/CD Enhancement

When improving the build pipeline, workflows, or automation:

### Steps

1. **Understand the current workflow**
   - Read `.github/workflows/export-web.yml`
   - Trace the build and deploy process
   - Identify the improvement area

2. **Make changes**
   - Edit workflow YAML
   - Add new steps or jobs
   - Update Docker configuration if needed

3. **Test locally (if possible)**
   ```bash
   # For Docker changes
   docker build -t test-image -f ci/docker/godot-4.6-headless.Dockerfile .
   
   # For workflow changes, use act (GitHub Actions local runner)
   act -j export-and-deploy
   ```

4. **Test in GitHub Actions**
   - Push to a feature branch
   - Monitor workflow execution
   - Check logs for errors

5. **Update documentation**
   - Document new workflow steps
   - Update setup instructions if needed
   - Add troubleshooting tips

### Example: Adding Cache for Dependencies

```yaml
- name: Cache Godot export templates
  uses: actions/cache@v4
  with:
    path: ~/.local/share/godot/export_templates
    key: godot-templates-${{ runner.os }}-4.6
```

## Feature Type: Docker Optimization

When improving the CI container image:

### Steps

1. **Identify optimization opportunity**
   - Reduce image size
   - Speed up build time
   - Update Godot version
   - Add new tools

2. **Modify Dockerfile**
   - Edit `ci/docker/godot-4.6-headless.Dockerfile`
   - Follow Docker best practices
   - Minimize layers

3. **Build and test locally**
   ```bash
   cd ci/docker
   ./build-image.sh
   
   # Test the image
   docker run --rm test-image --version
   ```

4. **Test export functionality**
   ```bash
   mkdir -p build/web
   docker run --rm -v "$(pwd):/work" -w /work test-image \
     --path ./project --export-release "Web" /work/build/web/index.html
   ```

5. **Update documentation**
   - Document Docker changes
   - Update build instructions
   - Note any breaking changes

### Example: Multi-stage Build

```dockerfile
# Stage 1: Download and prepare
FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y wget unzip
RUN wget -O /tmp/godot.zip https://github.com/godotengine/godot/releases/download/4.6-stable/...

# Stage 2: Runtime
FROM ubuntu:22.04
COPY --from=builder /usr/local/bin/Godot* /usr/local/bin/
```

## Feature Type: Documentation Improvement

When enhancing guides, tutorials, or examples:

### Steps

1. **Identify the gap**
   - What's confusing or missing?
   - What questions do users ask?
   - What's poorly explained?

2. **Research the topic**
   - Use Context7 MCP for current Godot docs
   - Test the process yourself
   - Gather examples

3. **Write clear documentation**
   - Use headings and structure
   - Include code examples
   - Add screenshots or diagrams
   - Provide step-by-step instructions

4. **Test the instructions**
   - Follow your own guide
   - Ask someone else to try it
   - Fix any unclear steps

5. **Place appropriately**
   - README.md: User-facing features, setup
   - CONTRIBUTING.md: Developer workflows
   - .github/prompts/: Copilot prompt files
   - New file: Detailed guides or tutorials

### Example: Adding Troubleshooting Section

```markdown
## Troubleshooting

### Export fails with "Could not find export template"

**Cause**: Export templates are not installed

**Solution**:
1. Open Godot editor
2. Go to Editor > Manage Export Templates
3. Download and install templates for version 4.6
4. Retry export
```

## Testing Checklist

Before submitting your feature:

- [ ] **Code quality**
  - Follows coding conventions
  - Includes type hints (GDScript)
  - Has clear variable/function names
  - No hardcoded values that should be configurable

- [ ] **Functionality**
  - Feature works as intended
  - No regressions in existing features
  - Handles edge cases

- [ ] **Testing**
  - Tested in Godot editor
  - Tested web export
  - Tested in CI/CD (if applicable)
  - Tested on multiple browsers (for web features)

- [ ] **Documentation**
  - Feature is documented
  - Code comments for complex logic
  - README updated if needed
  - CONTRIBUTING.md updated if workflow changes

- [ ] **Version control**
  - Clear commit messages
  - No unnecessary files committed
  - .gitignore updated if needed

## Common Patterns

### Adding a New Scene

```
1. Create in Godot editor
2. Add to project tree
3. Create corresponding script
4. Test locally
5. Test in web export
6. Document in README
```

### Modifying Export Settings

```
1. Open project in Godot
2. Project > Export
3. Edit "Web" preset
4. Save and commit export_presets.cfg
5. Test CI/CD workflow
```

### Adding Workflow Step

```
1. Edit .github/workflows/export-web.yml
2. Add new step with clear name
3. Test on feature branch
4. Check workflow logs
5. Document in README
```

## Getting Help

- **Godot questions**: Use Context7 MCP with Godot 4.6 docs
- **CI/CD questions**: Check GitHub Actions documentation
- **Project-specific**: Ask in issue or discussion
- **Architecture**: Read `.github/copilot-instructions.md`

## Examples of Good Features

- **Small and focused**: Adds one clear capability
- **Well-tested**: Works reliably in all scenarios
- **Documented**: Others can understand and use it
- **Maintainable**: Code is clean and follows conventions
- **Compatible**: Doesn't break existing functionality

## After Submission

1. Respond to review feedback promptly
2. Make requested changes
3. Keep the PR updated with main branch
4. Be patient during review process
5. Celebrate when merged! 🎉
