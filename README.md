# Roblox Script Collection

A comprehensive collection of Roblox game scripts, exploit utilities, tools, and MCP infrastructure.

## Overview

This repository contains scripts for various Roblox games including auto-farmers, ESP, silent aim, hitbox expanders, and universal tools. It also includes MCP (Model Context Protocol) infrastructure for connecting Roblox executor tools to AI agents.

## Structure

```
├── 01_Arcade_Shooter/        # Combat/Tycoon game scripts
├── 02_Artemis_Royale/        # Silent Aim + ESP
├── 03_Backflip_Brainrot/     # Auto-farm brainrots
├── 04_Become_Brainrot/       # OP auto-farm
├── 05_Brainrot_Tycoon/       # Auto-collect/upgrade/steal
├── 06_Millionaire_Tycoon/    # Cash farming
├── 07_DaBakingGame/          # Anti-cheat bypass
├── 08_Untitled_Melee_RNG/    # One-shot kill aura
├── ... (40+ game folders)
├── 20_Hitbox_Tools/          # Universal hitbox utilities
├── 21_Universal_Tools/       # Game dumpers, visualizers
├── 22_MCP_Infrastructure/    # MCP server setup for Windsurf
├── MCP_Access/               # Recon templates and docs
├── exw.lua                   # Universal game loader
└── brainrot_autofarm.luau    # Standalone autofarm script
```

## Key Files

- **`exw.lua`** — Universal game script loader with game selection UI
- **`_FOLDER_RULE.txt`** — Naming conventions and development rules
- **`22_MCP_Infrastructure/`** — MCP server configs and launchers for AI integration

## Games Supported

See `_SCRIPT_INDEX.md` for the full list of supported games and script descriptions.

## MCP Integration

This repo connects to Windsurf's Cascade agent via:
- `roblox-executor` MCP — In-game script execution, remote spy, UI automation
- `composio` MCP — Gmail, GitHub, and 500+ external tool integrations

## Usage

1. Load `exw.lua` into your Roblox executor
2. Select the game from the UI list
3. Click "Load" to run the game-specific script

## Disclaimer

These scripts are for educational purposes only. Use at your own risk.
