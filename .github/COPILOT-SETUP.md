# Quick Reference: GitHub Copilot Setup

This repository includes comprehensive GitHub Copilot agent instructions. Here's how to get started.

## For Users

### 1. Configure MCP Servers

Edit your MCP configuration file:
- **macOS/Linux**: `~/.config/Code/User/mcp.json`
- **Windows**: `C:\Users\USERNAME\AppData\Roaming\Code\User\mcp.json`

Add this configuration:

```json
{
  "servers": {
    "Context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

### 2. Enable MCP in VS Code

1. Reload VS Code (Command Palette > "Reload Window")
2. Open GitHub Copilot Chat
3. Click the **Tools** icon (⚙️)
4. Enable **Context7**

### 3. Use Copilot Prompts

In Copilot Chat, use these commands:

```
@workspace /onboarding-plan
→ Generate a personalized onboarding plan

@workspace /add-feature
→ Get step-by-step guidance for adding features

@workspace /troubleshooting
→ Diagnose and fix common issues

@workspace <your question>
→ Ask anything about the repository
```

## For Copilot Agent

The agent will automatically:
- Read `.github/copilot-instructions.md` on first use
- Follow repository conventions and architecture
- Use Context7 for Godot 4.6 documentation
- Provide precise, technical responses
- Match existing code patterns

## Key Files

- `.github/copilot-instructions.md` - Main agent configuration
- `.github/prompts/` - Prompt files for specific workflows
- `CONTRIBUTING.md` - Contribution guidelines
- `README.md` - Project overview and setup

## Learn More

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed information about:
- Development setup
- Coding standards
- Testing guidelines
- Pull request process

## Questions?

- Open an issue for bugs or feature requests
- Check existing documentation first
- Use `@workspace` in Copilot Chat for context-aware help
