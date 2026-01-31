# Godot 4.6 Web Template

A complete CI/CD setup for exporting Godot 4.6 projects to the web and automatically deploying to GitHub Pages.

## Features

- ✅ Godot 4.6 headless Docker container for CI
- ✅ Automated web export on push to main branch
- ✅ GitHub Pages deployment
- ✅ COOP/COEP service worker for SharedArrayBuffer support
- ✅ Ready-to-use project structure

## Repository Structure

```
godot-web-template/
├── project/                # Your Godot 4.6 project
│   ├── project.godot       # Main project file
│   ├── export_presets.cfg  # Export configuration
│   └── icon.svg            # Project icon
├── docs/                   # Web export output (overwritten by CI)
│   └── README.md           # Placeholder
├── ci/
│   └── docker/
│       └── godot-4.6-headless.Dockerfile  # Docker image for CI
└── .github/
    └── workflows/
        └── export-web.yml  # GitHub Actions workflow
```

## Setup Instructions

### 1. Build and Push Docker Image

First, you need to build the Godot 4.6 headless Docker image and push it to GitHub Container Registry (GHCR):

```bash
# Build the image
docker build -t ghcr.io/synapticore/godot-4.6-headless:web \
  -f ci/docker/godot-4.6-headless.Dockerfile .

# Login to GHCR (use a personal access token with write:packages scope)
echo $GITHUB_TOKEN | docker login ghcr.io -u synapticore --password-stdin

# Push the image
docker push ghcr.io/synapticore/godot-4.6-headless:web

# Make the package public (optional, or configure via GitHub UI)
```

**Note:** Update the image reference in `.github/workflows/export-web.yml` to match your username:
```yaml
container:
  image: ghcr.io/synapticore/godot-4.6-headless:web
```

### 2. Enable GitHub Pages

1. Go to your repository settings
2. Navigate to **Pages** section
3. Under **Build and deployment**, select **GitHub Actions** as the source

### 3. Develop Your Game

Add your game code and assets to the `project/` folder. The project is already configured with:
- Godot 4.6 compatibility
- GL Compatibility rendering method
- Web export preset

### 4. Push to Main Branch

When you push to the `main` branch, the GitHub Actions workflow will:
1. Export your project to WebAssembly
2. Add a service worker for cross-origin isolation
3. Deploy to GitHub Pages

Your game will be available at: `https://synapticore.github.io/godot-web-template/`

## Local Development

To work on your project locally, download and install [Godot 4.6](https://godotengine.org/download) and open the `project/` folder.

## Service Worker

The workflow automatically includes a service worker (`coi-serviceworker.js`) that sets the required headers for SharedArrayBuffer support:
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

This enables advanced features like threading and high-performance memory operations in your exported web game.

## Customization

- **Project Settings:** Edit `project/project.godot` using the Godot editor
- **Export Settings:** Modify `project/export_presets.cfg` for web export options
- **Workflow:** Customize `.github/workflows/export-web.yml` for different deployment options
- **Docker Image:** Adjust `ci/docker/godot-4.6-headless.Dockerfile` for different Godot versions

## Troubleshooting

### Workflow Fails with "Image not found"
- Ensure you've built and pushed the Docker image to GHCR
- Update the image reference in the workflow file to match your username
- Verify the package is public or the workflow has access to it

### Export Fails
- Check that `export_presets.cfg` is committed to the repository
- Verify the export preset name matches "Web" in the workflow

### Game Doesn't Load
- Check browser console for errors
- Verify COOP/COEP headers are set correctly
- Ensure all assets are included in the export

## License

This template is provided as-is for use in your own projects.
