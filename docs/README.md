# Web Export

This folder will be automatically populated by the GitHub Actions workflow with the exported web build.

The workflow will:
1. Export the Godot project to WebAssembly
2. Add a service worker for Cross-Origin headers (COOP/COEP)
3. Deploy the content to GitHub Pages

Do not manually edit files in this folder as they will be overwritten by the CI/CD pipeline.
