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

## Dependency Management

Update pinned dependencies:
```bash
nix-instantiate --option tarball-ttl 1 --strict --eval --arg update true sources.nix > sources.tmp && mv sources.tmp sources.lock
```

## Architecture

- `shell.nix` - Development environment definition with available tools
- `sources.nix` - Declarative dependency fetching (nixpkgs, devshell, agent-sandbox)
- `sources.lock` - Pinned dependency versions with commit hashes and narHashes
- `.envrc` - direnv configuration for automatic environment loading

The project uses a custom Nix dependency management approach (via `sources.nix`/`sources.lock`) rather than Nix Flakes. When `update=false` (default), `sources.nix` reads pinned revisions from `sources.lock` and fetches tarballs by SHA256; when `update=true`, it fetches latest commits via `builtins.fetchGit` and writes new lock data to stdout.

### Sandbox Mechanism

`shell.nix` uses `agent-sandbox.mkSandbox` (from the `agent-sandbox.nix` project) to wrap `claude-code` with a restricted closure. The sandbox:

- Limits the tools available to Claude to an explicit allowlist: `cacert`, `coreutils`, `which`, `bash`, `git`, `ripgrep`, `fd`, `gnused`, `gnugrep`, `findutils`, `jq`
- Grants access to Claude's state directories (`~/.claude/`) and config files (`~/.claude.json`, `~/.claude.json.lock`)
- Sets `NIX_SSL_CERT_FILE` for HTTPS access
- Uses `restrictClosure = true` to prevent access to packages outside the allowlist

### Managed Dependencies

Three sources are pinned in `sources.lock`:
- **nixpkgs** (`nixos-25.11` branch) - base package set; `allowUnfreePredicate` enables `claude-code`
- **devshell** (`numtide/devshell`) - provides `devshell.mkShell`
- **agent-sandbox** (`azuwis/agent-sandbox.nix`) - provides the sandbox wrapper
