# Deep Lure

A vertical endless descender about a deep-sea anglerfish navigating the abyss. Dodge obstacles, dash to walls with your bioluminescent lure, and survive as long as possible.

**Status:** Early development (Phase 3 of 6)

---

## Development

### Requirements

- [Godot 4.6](https://godotengine.org/download/) — use the **standard** build (not .NET/Mono)
- No additional dependencies

### Running the project

1. Clone or download the repository
2. Open Godot, click **Import** and select the project folder
3. Press **F5** or click the **Play** button to run

### Controls (desktop)

| Input | Action |
|-------|--------|
| A / ← | Move left |
| D / → | Move right |
| Space + A/D | Dash toward nearest wall |
| Space (no direction) | Dash downward |

### Project structure

```
chunks/     — hand-authored obstacle chunks (.tscn)
docs/       — design documents
scenes/     — main scenes (world, player, enemies, HUD)
scripts/    — GDScript source files
assets/     — art and audio (not yet populated)
```

### Design document

Full mechanics spec, art requirements, and phase plan: [`GDD.md`](GDD.md)

### What's next

- [ ] Remaining Phase 3 creatures: eel, squid, pufferfish
- [ ] Phase 4: ZoneManager, biomes, light mechanic
- [ ] Phase 5: Art and audio pass
- [ ] Phase 6: Menu, leaderboard, mobile export

---

## License

Copyright (c) 2026. All rights reserved. See [LICENSE](LICENSE).
