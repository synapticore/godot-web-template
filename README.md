# Godot 4.6 Web Template

A complete CI/CD setup for exporting Godot 4.6 projects to the web and automatically deploying to GitHub Pages.

## Features

- Automated Godot 4.6 web export on push to main
- GitHub Pages deployment with GitHub Actions
- Multi-threading support via coi-serviceworker (SharedArrayBuffer)
- Godot + export templates cached for fast CI builds
- Ready-to-use project structure

## Live Demo

https://synapticore.github.io/godot-web-template/

## Repository Structure

```
godot-web-template/
├── project/                    # Your Godot 4.6 project
│   ├── project.godot           # Main project file
│   ├── export_presets.cfg      # Export configuration
│   ├── coi-serviceworker.js    # COOP/COEP headers for SharedArrayBuffer
│   └── icon.svg                # Project icon
├── docs/                       # Web export output (overwritten by CI)
└── .github/
    └── workflows/
        └── export-web.yml      # GitHub Actions workflow
```

## Setup Instructions

### 1. Use This Template

Click "Use this template" on GitHub to create your own repository.

### 2. Enable GitHub Pages

1. Go to your repository **Settings**
2. Navigate to **Pages** section
3. Under **Build and deployment**, select **GitHub Actions** as the source

### 3. Develop Your Game

Add your game code and assets to the `project/` folder. The project is already configured with:
- Godot 4.6 compatibility
- GL Compatibility rendering method
- Web export preset with thread support

### 4. Push to Main Branch

When you push to the `main` branch, the GitHub Actions workflow will:
1. Install Godot 4.6 and export templates (cached for speed)
2. Export your project to WebAssembly
3. Inject coi-serviceworker for COOP/COEP headers
4. Deploy to GitHub Pages

Your game will be available at: `https://<username>.github.io/<repo-name>/`

## Local Development

### Prerequisites
- [Godot 4.6](https://godotengine.org/download) with export templates installed

### Export Locally

```bash
# Export web build
mkdir -p build/web
godot --headless --path ./project --export-release "Web" ../build/web/index.html

# Add service worker for local testing
cp project/coi-serviceworker.js build/web/
sed -i 's|<head>|<head><script src="coi-serviceworker.js"></script>|' build/web/index.html

# Start local server
cd build/web && python -m http.server 8888
# Open http://localhost:8888
```

## Thread Support & SharedArrayBuffer

Web exports use SharedArrayBuffer for multi-threading, which requires COOP/COEP headers:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

GitHub Pages doesn't support custom headers, so we use [coi-serviceworker](https://github.com/gzuidhof/coi-serviceworker) to inject them via service worker. On first visit, the page reloads once to activate the service worker.

## Customization

- **Project Settings:** Edit `project/project.godot` using the Godot editor
- **Export Settings:** Modify `project/export_presets.cfg` for web export options
- **Workflow:** Customize `.github/workflows/export-web.yml` for different deployment options
- **Godot Version:** Update download URLs in the workflow for different versions

## Troubleshooting

### Export Fails
- Check that `export_presets.cfg` is committed to the repository
- Verify the export preset name matches "Web" in the workflow

### Game Shows Black Screen
- Check browser console for errors
- Ensure coi-serviceworker.js is loaded (check for "COOP/COEP Service Worker registered" in console)
- Try refreshing - first load registers the service worker, second load runs the game

### Game Doesn't Load
- Verify all assets are included in the export
- Check that thread support is enabled in export_presets.cfg

## License

This template is provided as-is for use in your own projects.
