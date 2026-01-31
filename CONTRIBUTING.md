# Contributing

## Setup

1. Install [Godot 4.6](https://godotengine.org/download)
2. Install Docker (for CI work)
3. Clone and open `project/` in Godot

## Development

**Godot:** Edit in Godot editor, test with F5, export to web and test in browser.

**Docker:**
```bash
cd ci/docker && ./build-image.sh
```

**Test export locally:**
```bash
docker run --rm -v $(pwd):/work -w /work ghcr.io/synapticore/godot-4.6-headless:web \
  --path ./project --export-release "Web" ./build/index.html
```

## Code Style

GDScript: Follow [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) - use type hints.

## Pull Requests

1. Create feature branch
2. Test locally + web export
3. Push and create PR
