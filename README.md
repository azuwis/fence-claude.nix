# fence-claude

Nix-based sandboxed environment for [Claude Code](https://claude.ai/code) CLI using [fence](https://github.com/Use-Tusk/fence) ([bubblewrap](https://github.com/containers/bubblewrap) on Linux, Apple Sandbox on macOS).

## Features

- **Sandboxed execution** - Claude Code runs with restricted filesystem, network, and namespace isolation
- **Explicit tool allowlist** - only approved CLI tools (`git`, `ripgrep`, `fd`, `jq`, etc.) are accessible
- **No network by default** - network access is opt-in via configuration
- **Reproducible** - all dependencies are pinned with Nix

## Quick Start

```bash
# Add fence-claude to PATH (with direnv)
direnv allow

# Run Claude Code in the sandbox
fence-claude

# Pass arguments to claude and fence
fence-claude <claude_args> -- <fence_args>

# Or run directly without direnv
nix --extra-experimental-features nix-command run --file default.nix fence-claude -- <claude_args> -- <fence_args>

# Open a sandboxed shell (for inspecting/testing the sandbox)
nix --extra-experimental-features nix-command run --file default.nix fence-claude.shell
```

## Configuration

### Network Access

By default, network access is denied. To allow access to the Anthropic API, either:

1. Uncomment the `network` section in `nix/fence-claude.nix`
2. Or create `~/.config/fence/fence.json`:

```json
{
  "network": {
    "allowedDomains": [
      "*.anthropic.com"
    ]
  }
}
```

### Filesystem Access

The sandbox allows read/write access to:
- `.` (current working directory)
- `~/.claude/`
- `~/.claude.json`

All other filesystem access is denied by default.

## Updating Dependencies

```bash
nix-instantiate --option tarball-ttl 1 --strict --eval --arg update true nix/sources.nix > sources.tmp && mv sources.tmp nix/sources.lock
```
