# DEEP LURE — Design Document

> A vertical action scroller about a deep-sea anglerfish descending into the abyss, guided by its own bioluminescent lure.

---

## 1. Concept

The player controls a deep-sea anglerfish in an endless auto-descent. The lure on its head serves as both a movement tool (extends and grabs onto walls, pulling the fish sideways) and a source of dangerous light (attracts predators in darker zones). The goal is to descend as deep as possible. Score is measured in meters.

**Genre:** Vertical scroller / Dodge
**Platform:** PC (Godot 4), mobile later
**Mode:** Single player, high score

---

## 2. Gameplay

### Movement

- The fish auto-descends continuously
- Player controls horizontal movement: `A/D` or arrow keys
- No descent speed acceleration for now — constant speed, may be tuned per zone

### Lure Dash

The lure is the core mechanic — it replaces the old harpoon and works instantly via raycast:

- **Space + A/D held** → lure shoots sideways, grabs the nearest wall, fish snaps toward it (horizontal dash, stops DASH_OFFSET=40px from surface)
- **Space alone (no direction)** → lure shoots downward, fish rushes down to the nearest obstacle or DASH_RANGE=600px in open water
- ~1 sec cooldown after each use, visual indicator on fish body
- Horizontal dash: only works if a wall is within range (miss = cooldown, no dash)
- Downward dash: always works (accelerates descent through open space or to an obstacle above)

### Light (planned — Phase 4+)

The anglerfish's bioluminescent lure glows at all times. In deeper, darker zones this becomes a risk/resource tension:
- Light on → see obstacles, but attracts light-sensitive predators
- Light off (toggle) → blind descent, predators lose track of the fish
- Exact mechanic TBD — to be designed once biome system is in place

### Combat

No direct combat. Enemies are pure obstacles to dodge around. Future mechanic: collectibles (e.g. pressure charges) that can be triggered to destroy nearby threats.

### Death

- Touching any obstacle or enemy — instant death
- Result screen: depth in meters + restart button

---

## 3. Obstacles & Creatures

### Static Obstacles

- **Rocks / stone outcrops** — basic blockers, narrow the passage
- **Shipwreck debris** — irregular shapes, harder to navigate
- **Jellyfish** — float in place, lethal on touch

### Moving Creatures (all lethal on touch, dodge-only)

- **Piranha** — darts horizontally across the screen, bounces wall to wall
- **Eel** — lunges out of a wall and retracts, like a piston
- **Squid** — slowly drifts toward player from below
- **Pufferfish** — inflates when player approaches, lethal in expanded radius

---

## 4. Biomes (depth zones)

Biomes are one-way. Difficulty increases continuously within each zone. The final zone has no end.

| Zone          | Depth      | Lighting                        | New threats                                                                                          |
| ------------- | ---------- | ------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Sunlit Zone   | 0–500m     | Bright, clear                   | Rocks, jellyfish, piranhas — tutorial pacing                                                         |
| Twilight Zone | 500–1500m  | Dim blue                        | Shipwreck debris, eels appear                                                                        |
| Midnight Zone | 1500–3000m | Dark, bioluminescence only      | Squid, pufferfish, narrow passages; light mechanic activates                                         |
| Abyssal Zone  | 3000–5000m | Lure-light only (small radius)  | All creatures faster, visibility punishes hesitation                                                 |
| Hadal Trench  | 5000m+     | Near-total darkness             | Final zone — density and speed keep increasing indefinitely                                          |

---

## 5. Visual & Atmosphere

**Art style:** Hand-drawn 2D — organic shapes, visible brush strokes, slightly wobbly outlines. No pixel grid.

**Color palette per zone:**
- Sunlit Zone — warm turquoise, coral orange, bright whites
- Twilight Zone — deep blue, cold greens, fading light from above
- Midnight Zone — near-black background, glowing bioluminescent blues and greens
- Abyssal Zone — dark greys and blacks, lure creates a warm yellow cone against cold void
- Hadal Trench — desaturated, almost monochrome, with occasional deep red accents

**Atmosphere details:**
- Parallax background layers: distant rock formations, floating particles (sediment, bubbles)
- Anglerfish lure trails slightly ahead of the fish — bounces and glows
- Creature death: dissolves into ink-like cloud
- Zone transitions: gradual color shift over ~50m, no hard cuts

**Audio direction:**
- Ambient underwater hum, pressure sounds deepen with each zone
- Lure dash: wet snap + low thud on grab
- Death: sudden silence, then a low resonant tone

---

## 6. UI / HUD

Minimal — screen clutter is dangerous at high speed.

**In-game HUD:**
- **Depth counter** — top center, large readable font (e.g. `1 247 m`)
- **Dash cooldown** — visual indicator near the fish (color change: blue = ready, grey = recharging)
- **Current zone name** — fades in briefly on zone transition, then disappears
- No health bar (one-hit death), no score multiplier

**Death screen:**
- Depth reached (large)
- Personal best (if beaten — highlight it)
- Two buttons: Restart / Main Menu

**Main menu:**
- Title, Start, Leaderboard (local high scores), Settings
- Background: slow animated descent loop to set the mood

---

## 7. Technical Notes (Godot 4)

**Scene structure:**
- `World` — root, contains camera, spawner, player; handles game state
- `Player` — `CharacterBody2D`, horizontal movement + lure dash logic
- `SpawnerManager` — child of `World`, procedural chunk spawning
- `HUD` — `CanvasLayer`, depth counter + dash cooldown indicator

**Lure dash mechanics (current implementation):**
- Space + direction → instant `PhysicsRayQueryParameters2D` raycast in that direction
- Hit wall → dash toward impact point (`_dash_to = hit.x ± DASH_OFFSET, current player Y`)
- No wall → cooldown starts (horizontal miss)
- Space alone → downward raycast; dash to obstacle or full DASH_RANGE=600px in open water
- Dash animation: ease-out quad lerp over DASH_TIME=0.12s; descent continues during dash

**Player hitbox:** horizontal rectangle 70×30px (fish-shaped, wider than tall)

**Infinite world / procedural spawning:**
- `SpawnerManager` spawns chunks below the viewport, frees them when they exit above
- Chunks are hand-authored `.tscn` scenes in `chunks/`, selected randomly from a pool
- Depth tracked as float, converted to meters for display

**Chunk system:**
- Each chunk root (`Node2D` + `ChunkBase` script) carries `@export var height: float = 400.0`
- Chunk width: always **1080px**
- Chunk height: **must be divisible by 200** (default 400px)
- Anchor point: top-left `(0, 0)`
- Lethal obstacles: `StaticBody2D + CollisionShape2D`, group `"lethal"`
- Side walls: group `"wall"` (non-lethal, used for dash grab detection)

**Collision groups:**
- `"lethal"` — kills player on contact (rocks, jellyfish, piranhas, etc.)
- `"wall"` — non-lethal (side walls); lure can grab these for horizontal dash

**Spawn / despawn rules:**
- `SPAWN_AHEAD = 400px` — spawn when `last_chunk_bottom_y < camera_bottom_y + SPAWN_AHEAD`
- `DESPAWN_MARGIN = 200px` — free chunk when `chunk_bottom_y < camera_top_y - DESPAWN_MARGIN`

**Lighting (dark zones — planned):**
- `CanvasModulate` tints scene darker per zone
- Player carries a `PointLight2D` simulating lure glow
- Light-sensitive predators respond to `PointLight2D` energy level (future mechanic)

**Data persistence:**
- Local high score saved via `FileAccess` to a simple JSON file

---

## 8. Implementation Plan

### Approach
All phases use engine primitives (colored `Polygon2D`, `RectangleShape2D`, `CircleShape2D`) as stand-ins. Sprites and animations are added only after gameplay is validated.

---

### Phase 0 — Project Setup ✅
- [x] Godot 4 project, portrait 1080×1920, stretch mode `canvas_items`
- [x] Folder structure: `scenes/`, `scripts/`, `assets/`, `chunks/`

### Phase 1 — Core Loop ✅
- [x] Player: horizontal movement, auto-descend, death on collision
- [x] World: moving camera with lookahead
- [x] HUD: depth counter
- [x] Death state + restart

### Phase 2 — Lure Dash ✅
- [x] Instant raycast horizontal dash (Space + A/D)
- [x] Downward dash (Space alone)
- [x] Ease-out animation, continuous descent during dash
- [x] Cooldown + visual indicator

### Phase 3 — Obstacles & Creatures (in progress)
- [x] Rocks: 3 chunk variants (left wall, right wall, both walls)
- [x] Jellyfish: stationary, lethal on touch
- [x] Piranha: horizontal patrol, bounces off walls
- [ ] Eel: lunges from wall and retracts
- [ ] Squid: drifts toward player from below
- [ ] Pufferfish: inflates when player approaches

**Goal:** Dodge-only gameplay feels tense and readable.

---

### Phase 4 — Biomes & Difficulty Scaling
- [ ] `ZoneManager`: determines zone by depth, fires transition signals
- [ ] `CanvasModulate` changes color per zone
- [ ] Spawner adjusts chunk pool weights per zone
- [ ] Light mechanic: `PointLight2D` on player, light-sensitive predator behavior
- [ ] Zone name label fades in on transition

**Goal:** Game gets meaningfully harder and more atmospheric the deeper you go.

---

### Phase 5 — Polish Pass (art & audio)
- [ ] Replace all shapes with hand-drawn sprites
- [ ] Anglerfish animation: idle descent, dash recoil, death
- [ ] Lure animation: trails ahead, glows, bounces
- [ ] Parallax background layers per zone
- [ ] Creature death ink-cloud effect (`GPUParticles2D`)
- [ ] Audio: ambient, lure dash SFX, death SFX

---

### Phase 6 — Final
- [ ] Main menu with animated background loop
- [ ] Local leaderboard (top 10, saved to JSON)
- [ ] Mobile export: Android first, then iOS
- [ ] Playtesting: tune dash feel, cooldown, chunk density

---

## 9. Asset Specifications (for artist)

### Canvas & format
- **Resolution:** 1080 × [height]px (portrait)
- **Export:** PNG with transparency
- **Color profile:** sRGB
- File naming: `chunk_[biome]_[type]_[variant].png` — e.g. `chunk_sunlit_rock_01.png`

### Chunk sizes
Heights must be **multiples of 200px**: 200 / 400 / 600 / 800px.
Width is always **1080px**.

Top and bottom edges must be **clear passage** (no obstacles touching y=0 or y=height).

### Chunks — what is needed

| Biome | Type | Variants | Size (h) | Notes |
|-------|------|----------|----------|-------|
| Sunlit Zone (0–500m) | Rock outcrop | 3 | 400px | Protrusions from left or right wall; center passage ≥ 300px wide |
| Sunlit Zone | Jellyfish | 2 | 200px | Floating center, translucent body + tentacles |
| Twilight Zone (500–1500m) | Shipwreck debris | 3 | 600px | Irregular metal shapes, tilted beams |
| Midnight Zone (1500–3000m) | Rock — narrow | 3 | 400px | Passage narrows to ≤ 240px at tightest point |
| Midnight Zone | Bioluminescent rock | 2 | 400px | Same shape as rock but with glow details |
| Abyssal / Hadal | Stalactite cluster | 3 | 600px | Long spikes from ceiling / floor |

### Character — anglerfish

- Body: wide, flat fish silhouette ~70×30px at gameplay size (deliver at 2× = 140×60px)
- Lure: bioluminescent appendage protruding from forehead, glows warm yellow/green
- States needed: **Idle** (descending), **Dash** (lure extends, body lurches), **Dead** (limp, lure dims)
- No arms, no equipment — pure fish anatomy

### Creatures

| Creature | Size (px) | Movement | States needed |
|----------|-----------|----------|---------------|
| Piranha | 60×30 | Horizontal patrol | Swim |
| Eel | 40×120 | Lunges from wall | Retracted, Lunging |
| Squid | 80×80 | Slow drift toward player | Idle, Chase |
| Pufferfish | 60×60 → 120×120 | Inflates in place | Normal, Inflating |
| Jellyfish | 60×80 | Stationary, tentacles trail | Idle |

### VFX elements
- **Death cloud:** ink splatter, ~150×150px, 4–6 frames at 12fps
- **Lure trail:** soft glow line, 2–3px wide, fades behind lure tip
- **Dash impact spark:** small flash at grab point, 3 frames
- **Zone transition overlay:** soft gradient PNG, 1080×400px

### Background layers (parallax)
Each zone needs **3 layers**:
- **Layer 1 (far):** faint rock silhouettes, low contrast
- **Layer 2 (mid):** floating particles — sediment, bubbles, debris
- **Layer 3 (near):** cave wall texture strips, 1080px wide × seamlessly tileable vertically

Deliver as vertically-tileable PNGs per biome.

### Style reference
Hand-drawn 2D — organic shapes, visible brush strokes, slightly wobbly outlines. No pixel grid, no hard vector look. Reference: painterly mobile games (e.g. Alto's Odyssey, Oceanhorn atmosphere).
