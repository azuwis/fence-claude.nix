# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Nix-based development environment template that provides a sandboxed setup for Claude Code CLI with reproducible dependencies.

## Development Environment

Enter the development shell:
```bash
# Automatic (with direnv installed)
direnv allow  # First time only, then auto-loads on directory entry

# Manual
nix-shell
```

Or run directly without entering the shell:
```bash
nix --extra-experimental-features nix-command run --file default.nix fence-claude -- <claude_args> -- <fence_args>
```

## Dependency Management

Update pinned dependencies:
```bash
nix-instantiate --option tarball-ttl 1 --strict --eval --arg update true nix/sources.nix > sources.tmp && mv sources.tmp nix/sources.lock
```

## Architecture

- `default.nix` - Development environment definition with available tools
- `nix/sources.nix` - Declarative dependency fetching (nixpkgs, devshell)
- `nix/sources.lock` - Pinned dependency versions with commit hashes and narHashes
- `nix/fence-claude.nix` - Fenced Claude Code package with sandbox configuration
- `.envrc` - direnv configuration for automatic environment loading

The project uses a custom Nix dependency management approach (via `nix/sources.nix`/`nix/sources.lock`) rather than Nix Flakes. When `update=false` (default), `sources.nix` reads pinned revisions from `sources.lock` and fetches tarballs by SHA256; when `update=true`, it fetches latest commits via `builtins.fetchGit` and writes new lock data to stdout.

### Sandbox Mechanism

`nix/fence-claude.nix` uses [fence](https://github.com/Use-Tusk/fence) with `bubblewrap` to sandbox `claude-code`. The sandbox:

- Limits the tools available to Claude to an explicit allowlist: `bash`, `cacert`, `coreutils`, `fd`, `findutils`, `git`, `gnugrep`, `gnused`, `jq`, `ripgrep`, `which`
- Restricts filesystem access: strict deny-read by default, only the Nix closure, working directory, `~/.claude/`, and `~/.claude.json` are accessible
- No network access by default (can be configured in `~/.config/fence/fence.json` or by uncommenting the `network` section in `fence-claude.nix`)
- Sets `NIX_SSL_CERT_FILE` for HTTPS access
- Uses `bubblewrap` on Linux for namespace isolation (unshares all namespaces)
- Provides `fence-claude` wrapper: `fence-claude <claude_args> -- <fence_args>`

### Managed Dependencies

Two sources are pinned in `nix/sources.lock`:
- **nixpkgs** (`nixpkgs-unstable` branch) - base package set; `allowUnfreePredicate` enables `claude-code`
- **devshell** (`numtide/devshell`) - provides `devshell.mkShell`
