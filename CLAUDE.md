# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build Docker image
cd ci/docker && ./build-image.sh

# Test export locally with Docker (from repo root)
mkdir -p build/web
docker run --rm -v "$(pwd):/work" -w /work ghcr.io/synapticore/godot-4.6-headless:web \
  --path ./project --export-release "Web" /work/build/web/index.html

# Local preview (requires Python)
cd build/web && python -m http.server 8888
# Then open http://localhost:8888
```

Local development: Open `project/` in Godot 4.6 editor.

## Architecture

```
project/           # Godot 4.6 project (main.tscn, main.gd, export_presets.cfg)
docs/              # GitHub Pages output (overwritten by CI)
ci/docker/         # Dockerfile for headless Godot 4.6
.github/workflows/ # export-web.yml triggers on push to main
```

CI: Push to main → Docker exports WebAssembly → Service worker for COOP/COEP → GitHub Pages

## Deployment

Push to `main` → auto-deploys to https://synapticore.github.io/godot-web-template/

## Rules

- Never edit `.godot/` or `.import/` - auto-generated
- Always commit `export_presets.cfg` - required for CI
- `docs/` is ephemeral - overwritten on deploy
- Godot 4.6 specific - check version compatibility

## Code Style

GDScript: [Official Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) - use type hints.