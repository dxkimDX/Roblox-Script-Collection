<div align="center">

<h1> Roblox Script Collection</h1>

<p>
  <b>A curated library of open-source Roblox game scripts & utilities</b>
</p>

<p>
  <img src="https://img.shields.io/badge/Lua-5.1%2F5.2%2FLuau-blue?logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/Roblox-Platform-red?logo=roblox&logoColor=white" alt="Roblox">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Scripts-50%2B-orange" alt="Scripts">
</p>

</div>

---

## What is this?

A growing collection of **open-source scripts** for popular Roblox games. These scripts are written in Luau/Lua and cover a wide range of use cases: auto-farming, ESP, silent aim, hitbox utilities, tycoon automation, and more.

> **Disclaimer:** These scripts are provided for **educational and research purposes only**. The authors assume no responsibility for how they are used. Always respect Roblox's Terms of Service and individual game rules.

---

## Game Scripts

| # | Game | Scripts |
|---|------|---------|
| 01 | **Arcade Shooter** | ESP + Silent Aim (v1–v4) |
| 02 | **Artemis Royale** | Silent Aim + ESP |
| 03 | **Backflip Brainrot** | Auto-farm, rarity filters, godly tier farming |
| 04 | **Become Brainrot** | OP auto-farm |
| 05 | **Brainrot Tycoon** | Auto-collect, auto-upgrade, auto-steal |
| 06 | **Millionaire Tycoon** | Auto-cash, auto-walk, auto-buy, code redeemer |
| 07 | **DaBakingGame** | Safe exploit suite with anti-cheat bypass |
| 08 | **Untitled Melee RNG** | Kill aura, loot magnet, auto-collect, ESP |
| 09 | **Escape Waves** | Auto-farm |
| 10 | **Fight School** | Hitbox expansion / visualization |
| 11 | **Football Duels** | Catch assist / auto-catch |
| 12 | **Gym / Hoopz** | Auto green (perfect timing) |
| 13 | **Hack Vault** | OP auto-farm, brainrot farming |
| 14 | **Job Site** | Ghost type identifier / ESP |
| 15 | **Jump Escape Brainrots** | Auto-collect with zone detection |
| 16 | **Lucky Block** | Kick + teleport exploit |
| 17 | **Tsunami Brainrot** | Auto-collect |
| 18 | **UF Park** | Catch box / hitbox assist |
| 19 | **Active Brainrots** | Auto-farm |

> **See [`_SCRIPT_INDEX.md`](_SCRIPT_INDEX.md) for the complete list of 40+ supported games.**

---

## Universal Tools

These scripts work across **any** Roblox game:

- **`universal_game_dumper.lua`** — Dump and inspect the entire workspace hierarchy
- **`universal_hitbox_visualizer.lua`** — Visualize hitboxes in real-time
- **`DexDumper.lua`** — Dex explorer / advanced game inspector
- **Hitbox suite** — 9 specialized hitbox tools for diagnostics, scanning, and expansion testing

---

## How to Use

1. **Pick a game** from the folder list (e.g., `01_Arcade_Shooter/`)
2. **Open the script** you want in a Roblox script executor that supports Luau
3. **Run it** in-game

Each folder contains the relevant scripts for that specific game. File names are self-descriptive.

---

## Folder Structure

```
Roblox-Script-Collection/
├── 01_Arcade_Shooter/
├── 02_Artemis_Royale/
├── 03_Backflip_Brainrot/
├── ... (40+ game folders)
├── 20_Hitbox_Tools/
├── 21_Universal_Tools/
├── 22_MCP_Infrastructure/      # Setup docs for AI-powered workflows
├── MCP_Access/               # Game recon templates & docs
├── _FOLDER_RULE.txt          # Contribution guidelines
├── _SCRIPT_INDEX.md          # Full script catalog
├── README.md                 # You are here
├── brainrot_autofarm.luau    # Standalone autofarm script
└── exw.lua                   # Universal game loader
```

---

## Contributing

1. Follow the naming convention: `##_Game_Name`
2. Add your script to the correct folder
3. Update `_SCRIPT_INDEX.md` with a description
4. Keep it clean and well-commented

See `_FOLDER_RULE.txt` for full contribution rules.

---

## License

This project is provided as-is for educational purposes. Respect Roblox's ToS.

<div align="center">
  <sub>Built with Lua &mdash; for the Roblox community</sub>
</div>
