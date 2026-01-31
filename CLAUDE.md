# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Export locally (requires Godot 4.6 with export templates)
mkdir -p build/web
godot --headless --path ./project --export-release "Web" ../build/web/index.html

# Add COOP/COEP service worker for local testing
cp project/coi-serviceworker.js build/web/
sed -i 's|<head>|<head><script src="coi-serviceworker.js"></script>|' build/web/index.html

# Local preview (requires Python)
cd build/web && python -m http.server 8888
# Then open http://localhost:8888
```

Local development: Open `project/` in Godot 4.6 editor.

## Architecture

```
project/           # Godot 4.6 project (main.tscn, main.gd, export_presets.cfg)
project/coi-serviceworker.js  # COOP/COEP headers for SharedArrayBuffer
docs/              # GitHub Pages output (overwritten by CI)
.github/workflows/ # export-web.yml triggers on push to main
```

CI: Push to main → Godot 4.6 exports WebAssembly → coi-serviceworker for COOP/COEP → GitHub Pages

## Thread Support

Web exports use SharedArrayBuffer for multi-threading, which requires COOP/COEP headers.
GitHub Pages doesn't support custom headers, so we use [coi-serviceworker](https://github.com/gzuidhof/coi-serviceworker)
to inject them via service worker. The CI workflow automatically adds this to the build.

## Deployment

Push to `main` → auto-deploys to https://synapticore.github.io/godot-web-template/

## Rules

- Never edit `.godot/` or `.import/` - auto-generated
- Always commit `export_presets.cfg` - required for CI
- `docs/` is ephemeral - overwritten on deploy
- Godot 4.6 specific - check version compatibility

## Code Style

GDScript: [Official Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) - use type hints.