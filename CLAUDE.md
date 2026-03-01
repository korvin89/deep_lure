# Deep Lure — Claude Context

Godot 4.6, GDScript. Portrait 1080×1920, Mobile renderer. Not a git repository.
Design document: `GDD.md` — single source of truth for mechanics and art spec.

## Character

Deep-sea anglerfish. The lure = movement tool (dash to walls) and light source in dark zones. Not a diver, no harpoon.

## Architecture

```
scenes/world.tscn          — World > Camera2D, Player, LeftWall, RightWall, SpawnerManager
scripts/world.gd            — camera lookahead (X=540 fixed, Y=player+400), spawner.setup(camera)
scripts/player.gd           — state machine DESCENDING/PULLING, instant raycast dash
scripts/spawner_manager.gd  — class_name SpawnerManager, SPAWN_AHEAD=400, DESPAWN_MARGIN=200
scripts/chunk_base.gd       — class_name ChunkBase, @export var height: float = 400.0
scripts/jellyfish.gd        — StaticBody2D, groups=[lethal,enemy], die()→queue_free()
scripts/piranha.gd          — CharacterBody2D, patrol bounce off walls via get_slide_collision
```

## Dash mechanic (player.gd)

- **Space + A/D** → horizontal dash: instant raycast, `_start_dash(hit.x ± DASH_OFFSET, player.y)`
- **Space** (no direction) → downward dash: always works, to obstacle or full DASH_RANGE=600px
- Animation: ease-out quad lerp over DASH_TIME=0.12s; descent continues during dash
- After dash: `velocity=(0, descent_speed)`, state=DESCENDING, cooldown COOLDOWN=1.0s
- Horizontal miss (no wall in range) → cooldown, no dash

## Collision groups

- `"wall"` — non-lethal side walls; lure grabs these for horizontal dash
- `"lethal"` — kills player on contact (rocks, jellyfish, piranhas, etc.)
- `"enemy"` — no longer actively used; legacy group from old harpoon combat

## Chunks

```
chunks/chunk_rock_01.tscn      — 1080×400, rock from left wall
chunks/chunk_rock_02.tscn      — 1080×400, rock from right wall
chunks/chunk_rock_03.tscn      — 1080×400, both walls, center passage
chunks/chunk_jellyfish_01.tscn — 1080×200, jellyfish centered
chunks/chunk_piranha_01.tscn   — 1080×200, piranha centered
scenes/spawner_manager.tscn    — pool of all five chunks
```

Chunk rules: width always 1080px, height must be a multiple of 200px, anchor top-left (0,0).

## Phase status

- ✅ Phase 0: Project setup
- ✅ Phase 1: Core loop (player, camera, walls, HUD, death/restart)
- ✅ Phase 2: Lure dash (instant raycast, horizontal + downward, cooldown)
- 🔄 Phase 3: Obstacles & Creatures — done: rocks×3, jellyfish, piranha; remaining: eel, squid, pufferfish
- ⬜ Phase 4: ZoneManager, biomes, light mechanic
- ⬜ Phase 5: Art and audio
- ⬜ Phase 6: Menu, leaderboard, mobile export

## User preferences

- Language: Russian
- YAGNI strictly — reject over-engineering
- Small changes: implement directly; larger features: brainstorm → design doc → plan → implement
- Design decisions go into `GDD.md`
