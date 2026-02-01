# synapticore.studio Template

[![Deploy to GitHub Pages](https://github.com/synapticore-studio/godot-web-template/actions/workflows/export-web.yml/badge.svg)](https://github.com/synapticore-studio/godot-web-template/actions/workflows/export-web.yml)
[![Godot 4.6](https://img.shields.io/badge/Godot-4.6-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![WebAssembly](https://img.shields.io/badge/WebAssembly-654FF0?logo=webassembly&logoColor=white)](https://webassembly.org/)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-brightgreen?logo=github)](https://synapticore-studio.github.io/godot-web-template/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**Agentic DCC Pipelines & Interactive AI Experiences**

A professional Godot 4.6 project template with DCC pipeline utilities, color science, and an interactive 3D showcase.

## Live Demo

https://synapticore-studio.github.io/godot-web-template/

## Features

### Showcase
- Interactive 3D viewport with OrbitCamera (drag to rotate, scroll to zoom)
- Material presets (Default, Metallic, Glossy, Matte, Emissive)
- Lighting presets (Studio, Dramatic, Soft, Sunset)
- Post-processing presets (Warm, Cool, High Contrast, Desaturated)

### Starter Kit
- **Autoload Singletons:** SignalBus, Settings, AudioManager, GameManager
- **Scene Management:** Fade transitions, state machine
- **Settings System:** Persistent save/load via ConfigFile
- **Audio System:** Music fade, SFX pooling, bus control
- **Debug Overlay:** FPS, memory, draw calls (F3)

### DCC Utilities
- **ColorUtils:** sRGB/Linear conversion, ACES tonemapping, Rec.2020/DCI-P3, Kelvin to RGB
- **InputUtils:** Mouse, touch, deadzone handling, web pointer lock
- **Shaders:** Color grading, Studio PBR, gradient background

## Project Structure

```
project/
├── autoloads/           # Singleton managers
│   ├── signal_bus.gd    # Global event bus
│   ├── settings.gd      # Persistent preferences
│   ├── audio_manager.gd # Music/SFX handling
│   └── game_manager.gd  # App state & scenes
├── scenes/
│   ├── main/            # Entry point
│   ├── ui/              # UI components
│   └── showcase/        # 3D demo scene
├── components/
│   └── camera/          # OrbitCamera prefab
├── resources/
│   ├── themes/          # UI themes
│   └── shaders/         # Shader library
└── utils/
    ├── color_utils.gd   # Color science helpers
    └── input_utils.gd   # Input handling
```

## Quick Start

### Use as Template

1. Click "Use this template" on GitHub
2. Enable GitHub Pages (Settings → Pages → Source: GitHub Actions)
3. Push to main - auto-deploys to `https://<user>.github.io/<repo>/`

### Local Development

```bash
# Open in Godot 4.6
godot --path ./project

# Export web build
godot --headless --path ./project --export-release "Web" ../docs/index.html
```

## Controls

| Input | Action |
|-------|--------|
| Mouse drag | Rotate camera |
| Scroll | Zoom in/out |
| Touch drag | Rotate (mobile) |
| Pinch | Zoom (mobile) |
| F3 | Toggle debug overlay |
| Esc | Reset / Back |

## CI/CD

Push to `main` triggers automatic:
1. Godot 4.6 web export
2. SharedArrayBuffer headers injection
3. GitHub Pages deployment

## License

MIT License - see [LICENSE](LICENSE)

---

Made with [Godot Engine](https://godotengine.org/) by [synapticore.studio](https://github.com/synapticore-studio)
