---
mode: 'agent'
description: 'Generate a phased onboarding plan for new contributors to the Godot Web Template repository'
---

# Onboarding Plan Generator

You are helping a new contributor understand and get started with the **Godot 4.6 Web Template** repository. Generate a comprehensive, phased onboarding plan that helps them become productive contributors.

## Context

This repository provides a complete CI/CD setup for exporting Godot 4.6 projects to the web and deploying them to GitHub Pages. It includes:

- A minimal Godot 4.6 project structure
- Docker-based CI build system
- GitHub Actions workflows for automated deployment
- Service worker integration for advanced web features

## Your Task

Generate a personalized onboarding plan based on the contributor's background and interests. The plan should be divided into phases, each building on the previous one.

## Phase 1: Environment Setup (Day 1)

Provide step-by-step instructions for:

1. **Clone and explore the repository**
   - How to clone the repo
   - Key directories and files to examine first
   - Understanding the repository structure

2. **Install required tools**
   - Godot 4.6 installation
   - Docker Desktop (for CI testing)
   - Git configuration
   - Code editor setup (VS Code with Godot extension recommended)

3. **Read core documentation**
   - README.md - overall project goals
   - CONTRIBUTING.md - contribution guidelines
   - .github/copilot-instructions.md - Copilot agent behavior
   - .github/workflows/export-web.yml - CI/CD pipeline

4. **Verify local Godot setup**
   - Open `project/` in Godot 4.6 editor
   - Run the sample scene (main.tscn)
   - Test export to web locally
   - Verify the exported game runs in a browser

## Phase 2: Understanding the Architecture (Days 2-3)

Help the contributor understand:

1. **Godot project structure**
   - project.godot configuration
   - export_presets.cfg for web export
   - Scene and script organization
   - Asset management

2. **CI/CD pipeline**
   - Docker image for headless Godot
   - GitHub Actions workflow steps
   - Build and export process
   - Deployment to GitHub Pages

3. **Service worker integration**
   - Godot 4.6's built-in PWA service worker (index.service.worker.js)
   - COOP/COEP headers for SharedArrayBuffer (handled automatically)
   - PWA features: offline support, installable app

4. **Docker container**
   - Dockerfile structure for Godot 4.6
   - Export template installation
   - How to build and test locally

## Phase 3: Making First Contribution (Days 4-5)

Guide the contributor through a small, meaningful first contribution:

1. **Choose a starter task**
   - Look for issues labeled "good first issue"
   - Suggest improvements to documentation
   - Add a simple feature to the sample project
   - Enhance the README with troubleshooting steps

2. **Development workflow**
   - Create a feature branch
   - Make changes following coding conventions
   - Test changes locally
   - Commit with clear messages

3. **Testing**
   - Test the Godot project in the editor
   - Export to web and verify in browser
   - Test Docker image build (if modified)
   - Verify CI/CD workflow (if modified)

4. **Pull request**
   - Write a clear PR description
   - Link to relevant issues
   - Respond to review feedback
   - Iterate until approved

## Phase 4: Advanced Topics (Week 2+)

For contributors ready to go deeper:

1. **Advanced Godot features**
   - Adding new scenes and game mechanics
   - Optimizing for web export
   - Working with Godot 4.6 specific features
   - Performance profiling

2. **CI/CD enhancements**
   - Optimizing build times
   - Adding automated tests
   - Multiple export targets
   - Versioning and releases

3. **Docker optimization**
   - Multi-stage builds
   - Layer caching strategies
   - Using different Godot versions
   - Custom export templates

4. **Community engagement**
   - Help other new contributors
   - Review pull requests
   - Propose new features
   - Improve documentation

## Customization Prompts

Ask the contributor:

1. **What's your experience level?**
   - New to Godot? Focus on Godot basics first
   - New to Docker? Provide more Docker context
   - New to CI/CD? Explain GitHub Actions in detail
   - Experienced with all? Skip basics, focus on architecture

2. **What interests you most?**
   - Game development in Godot? Focus on project/ structure
   - DevOps/CI/CD? Focus on workflows and Docker
   - Web technologies? Focus on service workers and export
   - Documentation? Focus on README and guides

3. **How much time can you commit?**
   - Few hours a week? Suggest documentation improvements
   - Several hours a week? Suggest feature additions
   - Full-time contributor? Suggest architectural improvements

4. **What would you like to learn?**
   - Godot 4.6 features
   - Docker containerization
   - GitHub Actions workflows
   - Web export optimization

## Expected Outputs

Generate a markdown document with:

1. **Personalized timeline** (based on their availability)
2. **Specific tasks** for each phase (with links to relevant docs)
3. **Learning resources** tailored to their gaps
4. **Success metrics** for each phase
5. **Support channels** (where to ask questions)

## Success Criteria

A contributor has successfully onboarded when they can:

- Open and run the Godot project locally
- Understand the CI/CD pipeline flow
- Make a small contribution independently
- Navigate the codebase with confidence
- Know where to find documentation and help

## Example Interaction

**User**: "I'm new to Godot but experienced with Docker and CI/CD. I have about 5 hours a week to contribute."

**Your response should include**:
- Phase 1: Focus on Godot editor basics (2-3 hours)
- Phase 2: Quick review of CI/CD (30 minutes, since familiar)
- Phase 3: Suggest a CI/CD improvement task (1-2 hours)
- Phase 4: Propose Docker optimization projects
- Timeline: 2-3 weeks to complete all phases
- Resources: Link to Godot docs, GDScript tutorials
- First task: Add a troubleshooting section for Docker issues

## Notes

- Always check `.github/copilot-instructions.md` for the latest architecture and conventions
- Refer to `README.md` for current setup instructions
- Suggest reading `CONTRIBUTING.md` before making first contribution
- Encourage using GitHub Copilot with Context7 MCP for learning Godot APIs
- Be supportive and encouraging - every contributor started somewhere!
