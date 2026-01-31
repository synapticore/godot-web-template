# Contributing

## Setup

1. Install [Godot 4.6](https://godotengine.org/download) with export templates
2. Clone and open `project/` in Godot

## Development

**Godot:** Edit in Godot editor, test with F5, export to web and test in browser.

**Test export locally:**
```bash
# Export
mkdir -p build/web
godot --headless --path ./project --export-release "Web" ../build/web/index.html

# Add service worker
cp project/coi-serviceworker.js build/web/
sed -i 's|<head>|<head><script src="coi-serviceworker.js"></script>|' build/web/index.html

# Serve
cd build/web && python -m http.server 8888
```

## Code Style

GDScript: Follow [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) - use type hints.

## Pull Requests

1. Create feature branch
2. Test locally + web export
3. Push and create PR
