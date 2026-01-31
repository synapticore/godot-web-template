---
mode: 'agent'
description: 'Troubleshoot common issues in the Godot Web Template repository'
---

# Troubleshooting Guide

You are helping a user diagnose and fix issues with the **Godot 4.6 Web Template**. Use this systematic approach to identify and resolve problems.

## General Diagnostic Approach

1. **Gather information**
   - What were you trying to do?
   - What did you expect to happen?
   - What actually happened?
   - Any error messages?
   - What's your environment (OS, versions)?

2. **Check the basics**
   - Is Godot 4.6 installed?
   - Is Docker running (for CI issues)?
   - Are you on the correct branch?
   - Are there uncommitted changes?

3. **Review recent changes**
   - What was the last working state?
   - What changed since then?
   - Can you reproduce in a clean clone?

## Issue Category: Godot Project Won't Open

### Symptoms
- Error when opening project in Godot editor
- "Cannot open project" message
- Project loads but shows errors

### Diagnosis Steps

1. **Check Godot version**
   ```bash
   godot --version
   # Should be 4.6.x
   ```

2. **Verify project.godot exists**
   ```bash
   ls -la project/project.godot
   ```

3. **Check for corruption**
   ```bash
   # Validate project.godot syntax
   cat project/project.godot
   # Should be valid INI format
   ```

4. **Check .godot directory**
   ```bash
   # Remove and regenerate if corrupted
   rm -rf project/.godot
   # Reopen in Godot editor
   ```

### Solutions

**Wrong Godot version**: Install Godot 4.6 specifically

**Corrupted .godot folder**: Delete and let Godot regenerate

**Missing files**: Ensure all project files are committed and pulled

**Invalid project.godot**: Restore from git history or fix syntax

## Issue Category: Web Export Fails

### Symptoms
- Export produces errors
- Exported files are missing
- Web build doesn't work in browser

### Diagnosis Steps

1. **Check export templates**
   - Open Godot editor
   - Editor > Manage Export Templates
   - Verify 4.6 templates are installed

2. **Verify export preset**
   ```bash
   # Check export_presets.cfg exists
   cat project/export_presets.cfg | grep "name=\"Web\""
   ```

3. **Test export manually**
   - Project > Export in Godot editor
   - Select "Web" preset
   - Export to a test folder
   - Check for errors in console

4. **Verify exported files**
   ```bash
   # Should contain .html, .js, .wasm, .pck files
   ls -la build/web/
   ```

### Solutions

**Missing templates**: Install export templates via Godot editor

**No Web preset**: Commit `export_presets.cfg` from working local setup

**Export errors**: Check Godot console for specific errors

**MIME type issues**: Ensure server serves .wasm with correct content-type

## Issue Category: CI/CD Pipeline Fails

### Symptoms
- GitHub Actions workflow fails
- Docker image not found
- Export step fails in CI

### Diagnosis Steps

1. **Check workflow status**
   - Go to GitHub Actions tab
   - Find the failed workflow run
   - Examine error logs

2. **Verify Docker image**
   ```bash
   # Check if image exists in GHCR
   docker pull ghcr.io/synapticore/godot-4.6-headless:web
   ```

3. **Check workflow file**
   ```bash
   # Validate YAML syntax
   yamllint .github/workflows/export-web.yml
   ```

4. **Check permissions**
   - Go to repository Settings > Actions
   - Verify workflow permissions
   - Check GITHUB_TOKEN permissions

### Solutions

**Image not found**: Build and push Docker image to GHCR
```bash
cd ci/docker
./build-image.sh
docker push ghcr.io/synapticore/godot-4.6-headless:web
```

**Permission denied**: Update workflow permissions in YAML
```yaml
permissions:
  contents: write
  pages: write
  id-token: write
```

**Export fails**: Verify export preset exists and is committed

**Deployment fails**: Enable GitHub Pages in repository settings

## Issue Category: Docker Build Fails

### Symptoms
- Docker build produces errors
- Image build succeeds but export fails
- Container won't start

### Diagnosis Steps

1. **Check Docker installation**
   ```bash
   docker --version
   docker info
   ```

2. **Review Dockerfile**
   ```bash
   cat ci/docker/godot-4.6-headless.Dockerfile
   ```

3. **Test build locally**
   ```bash
   docker build -t test-godot -f ci/docker/godot-4.6-headless.Dockerfile .
   ```

4. **Check download URLs**
   ```bash
   # Verify Godot download URL is accessible
   wget -O /tmp/test.zip https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip
   ```

### Solutions

**Docker not installed**: Install Docker Desktop

**Network issues**: Check internet connection, try again

**Invalid URL**: Update Godot download URL in Dockerfile

**Build fails at specific layer**: Check that layer's commands, fix syntax

## Issue Category: Deployed Site Doesn't Work

### Symptoms
- Site deploys but shows blank page
- Game doesn't load in browser
- Console shows errors

### Diagnosis Steps

1. **Check browser console** (F12)
   - Look for JavaScript errors
   - Check Network tab for failed requests
   - Verify MIME types

2. **Verify deployment**
   ```bash
   # Check GitHub Pages settings
   # Repository > Settings > Pages
   # Should show site URL
   ```

3. **Check file structure**
   ```bash
   # Verify docs/ contains exported files
   ls -la docs/
   # Should have index.html, .js, .wasm, .pck, etc.
   ```

4. **Test COOP/COEP headers**
   - Open browser DevTools > Network
   - Reload page
   - Check response headers
   - Should include Cross-Origin headers

### Solutions

**Blank page**: Check browser console for specific errors

**Files not loading**: Verify all files deployed to docs/

**WASM not loading**: Check MIME type configuration

**SharedArrayBuffer errors**: Verify service worker is working

**Wrong base path**: Ensure Godot export uses correct base path

## Issue Category: Service Worker Issues

### Symptoms
- SharedArrayBuffer not available
- COOP/COEP headers not set
- Service worker not registering

### Diagnosis Steps

1. **Check Godot's built-in service worker**
   ```bash
   # Godot 4.6 generates this automatically when PWA is enabled
   cat docs/index.service.worker.js
   # Look for: ENSURE_CROSSORIGIN_ISOLATION_HEADERS = true
   ```

2. **Verify PWA is enabled**
   ```bash
   grep "progressive_web_app/enabled" project/export_presets.cfg
   # Should show: progressive_web_app/enabled=true
   ```

3. **Check browser DevTools**
   - Application > Service Workers
   - Should show `index.service.worker.js` registered
   - Check for errors

4. **Verify headers**
   - Network tab > Response Headers
   - Should include COOP and COEP after service worker is active

### Solutions

**Service worker missing**: Enable PWA in export_presets.cfg (`progressive_web_app/enabled=true`)

**Headers not set**: Godot 4.6's service worker handles this automatically - ensure `ENSURE_CROSSORIGIN_ISOLATION_HEADERS = true` in the generated service worker

**Not registering**: Clear browser cache/service workers and reload

**First load issue**: Service worker needs one page load to register, then headers work on reload

## Issue Category: Performance Issues

### Symptoms
- Slow export times
- Large build artifacts
- Slow game loading in browser

### Diagnosis Steps

1. **Check export size**
   ```bash
   du -sh docs/
   ls -lh docs/*.wasm
   ```

2. **Profile export process**
   - Note export time in CI logs
   - Compare with local export time

3. **Check asset optimization**
   - Are textures compressed?
   - Are audio files optimized?
   - Any unnecessary assets?

### Solutions

**Large WASM**: Review export settings, enable compression

**Slow CI**: Add caching for Docker layers and templates

**Slow loading**: Optimize assets, enable streaming

**Large assets**: Compress textures, reduce quality where acceptable

## Common Error Messages

### "Could not find export template"
- **Cause**: Export templates not installed
- **Fix**: Install via Godot editor or verify CI image

### "Failed to export project"
- **Cause**: Invalid export preset or missing files
- **Fix**: Check export_presets.cfg and verify all assets exist

### "Permission denied" in CI
- **Cause**: Insufficient workflow permissions
- **Fix**: Update permissions in workflow YAML

### "Image not found" in workflow
- **Cause**: Docker image not in GHCR or wrong reference
- **Fix**: Build and push image, update workflow image reference

### "Failed to deploy to GitHub Pages"
- **Cause**: Pages not enabled or wrong configuration
- **Fix**: Enable Pages in settings, use GitHub Actions as source

## Advanced Debugging

### Enable Verbose Logging

**In Godot:**
```bash
godot --verbose project/project.godot
```

**In Docker:**
```bash
mkdir -p build/web
docker run --rm -v "$(pwd):/work" -w /work \
  ghcr.io/synapticore/godot-4.6-headless:web \
  --verbose --path ./project --export-release "Web" /work/build/web/index.html
```

**In GitHub Actions:**
```yaml
- name: Export Web
  run: |
    echo "::group::Export logs"
    $GODOT_BIN --verbose --path ./project --export-release "Web" ../build/web/index.html
    echo "::endgroup::"
```

### Test in Isolation

1. **Fresh clone**
   ```bash
   git clone <repo-url> test-clone
   cd test-clone
   ```

2. **Clean Docker build**
   ```bash
   docker build --no-cache -t test -f ci/docker/godot-4.6-headless.Dockerfile .
   ```

3. **Minimal reproduction**
   - Create new minimal Godot project
   - Test same export process
   - Identify differences

## When to Ask for Help

If you've tried the above and still stuck:

1. **Open an issue** with:
   - Detailed description of the problem
   - Steps to reproduce
   - Error messages and logs
   - Your environment details
   - What you've already tried

2. **Use GitHub Discussions** for:
   - Questions about usage
   - Feature suggestions
   - General help

3. **Check existing issues** first:
   - Search for similar problems
   - See if already solved
   - Add info to existing issue if relevant

## Prevention Tips

- **Always test locally before pushing**
- **Keep Godot and export templates updated**
- **Commit export_presets.cfg**
- **Don't edit generated files (.godot/, .import)**
- **Test web export in multiple browsers**
- **Monitor CI/CD workflow regularly**

## Quick Reference

```bash
# Test Godot project
godot project/project.godot

# Build Docker image
cd ci/docker && ./build-image.sh

# Test Docker export
mkdir -p build/web
docker run --rm -v "$(pwd):/work" -w /work ghcr.io/synapticore/godot-4.6-headless:web \
  --path ./project --export-release "Web" /work/build/web/index.html

# Clean build
rm -rf project/.godot build/ docs/
```
