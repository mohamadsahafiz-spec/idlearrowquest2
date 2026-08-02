# Changelog

## [0.2.0] - Unreleased

### Added
- Implemented Milestone 3 Stage + Wave Foundation:
  - **Stage System (`StageSystem`)**:
    - Created modular `StageSystem` node tracking `current_stage`, `current_wave`, `total_waves`, `enemies_killed_this_wave`, `enemies_required_this_wave`, and `stage_active`.
    - Initialized Stage 1 wave progression: Wave 1 = 5 enemies, Wave 2 = 8 enemies, Wave 3 = 12 enemies (Total Waves = 3).
    - Modular stage configuration structure ready for future stage scaling.
  - **Controlled Wave Progression**:
    - Enforced single active wave execution with controlled enemy spawns.
    - Added wave completion transition delay (1.8s) displaying `"WAVE COMPLETE"` banner overlay before launching the next wave.
    - Completed Wave 3 progression displaying `"BOSS INCOMING"` transition state without auto-spawning the boss.
  - **Controlled Enemy Spawning & Combat Integration**:
    - Integrated weighted Normal / Strong / Elite enemy tier pool with `StageSystem`.
    - Prevented infinite respawning once a wave's required enemy count is fulfilled.
    - Preserved complete combat pipeline: spawn → movement → defender targeting → projectile → damage/critical → enemy HP → enemy attack → defender HP → death → reward → kill registration.
    - Kept Boss excluded from normal wave pool with `test_spawn_boss = false` by default.
  - **Stage HUD (`HUDPlaceholder`)**:
    - Added real-time Stage & Wave progress badge displaying Stage 1, Wave X / 3, and Enemies Y / Z.
    - Added center-screen banner overlay for `"WAVE COMPLETE"` and `"BOSS INCOMING"` states.
    - Preserved total "Kill Enemies: X" counter.

### Fixed
- Fixed GDScript `StageSystem` type resolution in `arena_placeholder.gd` and `battle.gd` using explicit script preloading.

## [0.1.8] - Unreleased

### Added
- Implemented Combat Presentation & Milestone 2 Combat Replica Integration:
  - **Damage Number Presentation**:
    - Improved readability with crisp drop shadows and outlines.
    - Normal damage numbers remain clean and lightweight (`-15`).
    - Critical hits prominently display `"CRIT -30"` in vibrant golden amber with larger font scale, scale pop bounce, and starburst arc.
    - Enemy damage against defender is visually distinct (`-10`) rendered in vivid crimson-orange with dark outline and pop bounce.
    - Prevented heavy damage number overlap during rapid hits by implementing horizontal and vertical position staggering.
  - **Combat Feedback Polish**:
    - Added Godot-native hit flash highlight rim and expanding hit spark rings on enemy `take_damage`.
    - Added hit flash pulse ring around defender shield and crystal when taking damage.
    - Added projectile trailing flare and distinct critical projectile visual (golden starburst aura & tail).
    - Polished enemy death dissolve feedback with fading shadow, expanding burst ring, core spark, and dissolving diamond line fragments.
    - Preserved distinct visual styling and tier labels for Normal, Strong, Elite, and Boss enemies.
  - **Milestone 2 Integration & Stability**:
    - Verified complete combat pipeline: enemy spawn → movement → defender targeting → projectile firing → normal/critical damage → enemy HP → enemy attack → defender HP → enemy death → reward → kill counter → respawn.
    - Confirmed shared combat pipeline across all enemy tiers (Normal, Strong, Elite, Boss).
    - Preserved `test_spawn_boss = false` by default in `ArenaPlaceholder`.
    - Maintained zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.7] - Unreleased

### Added
- Implemented modular Boss enemy foundation using existing combat architecture:
  - Added `Tier.BOSS` to `EnemyStats` with substantially higher stats (`max_hp = 1500.0`, `attack = 75.0`, `reward = 200`, `radius_multiplier = 2.2`).
  - Implemented dual-ring aura visual effect, golden core glow, and distinct `"BOSS"` label rendering in `EnemyPlaceholder`.
  - Created `spawn_boss()` method and `test_spawn_boss` test toggle in `ArenaPlaceholder` for manual/test spawning.
  - Enforced single-boss constraint ensuring only one Boss can exist in the arena at a time.
  - Preserved standard weighted spawning (`70% Normal`, `25% Strong`, `5% Elite`) when Boss test spawning is disabled.
  - Maintained full movement, targeting, projectile hits, critical hits, defender damage, rewards, and kill counter pipeline with zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.6] - Unreleased

### Added
- Implemented modular enemy tier system (Normal, Strong, Elite) powered by `EnemyStats`:
  - Defined `Tier` enum (`NORMAL`, `STRONG`, `ELITE`) and modular `EnemyStats.create_for_tier()` factory method.
  - Configured baseline stats for Normal tier (`max_hp = 100.0`, `attack = 10.0`, `reward = 10`).
  - Configured scaled stats for Strong tier (`max_hp = 220.0`, `attack = 18.0`, `reward = 25`).
  - Configured scaled stats for Elite tier (`max_hp = 500.0`, `attack = 35.0`, `reward = 60`).
  - Implemented configurable weighted spawning in `ArenaPlaceholder` (`70% Normal`, `25% Strong`, `5% Elite`).
  - Added Godot-native visual distinctions for each tier (custom color schemes, radius scale multipliers, aura rings, and tier text labels).
  - Preserved movement, targeting, projectiles, critical hits, defender HP/damage, rewards, respawns, and kill tracking with zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.5] - Unreleased

### Added
- Implemented first enemy-to-defender combat interaction:
  - Configured configurable `max_hp` (100.0) and `current_hp` tracking on `DefenderPlaceholder` via `DefenderStats`.
  - Added enemy attack state transition (`is_attacking = true`) when an enemy reaches the central platform destination.
  - Implemented continuous enemy attack loop targeting defender with cadence derived from `EnemyStats` (`attack = 10.0`, `attack_speed = 1.0`).
  - Added rendered defender HP bar and floating damage popups (`-10`) on hit.
  - Ensured safe defender HP clamping at 0.0 with defender remaining active for continuous testing.
  - Maintained defender auto-targeting and projectile firing simultaneously during enemy attacks.
  - Maintained zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.4] - Unreleased

### Added
- Connected enemy combat behavior fully to `EnemyStats`:
  - Added helper accessors `get_max_hp()`, `get_movement_speed()`, `get_reward()`, `get_attack_damage()`, `get_attack_speed()`, and `get_attack_cooldown()` to `EnemyStats`.
  - Updated `EnemyPlaceholder` computed properties (`max_hp`, `speed`, `coin_reward`, `attack`, `attack_speed`, `attack_cooldown`) to delegate directly to `EnemyStats`.
  - Prepared `attack` and `attack_speed` stats as modular accessors ready for future enemy attack capabilities without modifying current non-attacking behavior.
  - Preserved existing balance (`max_hp = 100.0`, `movement_speed = 85.0`, `reward = 10`) and full gameplay loop stability with zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.3] - Unreleased

### Added
- Implemented critical hits powered by `DefenderStats`:
  - Added `calculate_hit_damage()`, `get_critical_chance()`, and `get_critical_damage_multiplier()` methods to `DefenderStats` using `critical_chance` and `critical_damage` stats as single source of truth.
  - Updated `DefenderPlaceholder` to roll critical hits when firing projectiles (`base_damage` or `base_damage * critical_damage`).
  - Passed critical hit state through `ProjectilePlaceholder` to `EnemyPlaceholder.take_damage(amount, is_critical)`.
  - Added distinct floating damage numbers for critical hits (e.g. `"CRIT -30"` rendered in golden yellow at larger font scale).
  - Preserved all existing combat loop, targeting, range, death, reward, respawn, and kill-count behavior with zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.2] - Unreleased

### Added
- Implemented range system fully governed by `DefenderStats`:
  - Added `get_attack_range()` helper method to `DefenderStats`.
  - Updated `DefenderPlaceholder` targeting and firing logic to strictly validate target proximity against `attack_range`.
  - Added target distance range checks (`_is_enemy_in_range(enemy)`) in target acquisition, target loss validation, and projectile firing triggers.
  - Cleared target automatically when an enemy moves out of range and reacquires valid enemies upon entering range.
  - Preserved existing range balance (`range = 240.0`) and zero GDScript errors/warnings under Godot 4.7.1.

## [0.1.1] - Unreleased

### Added
- Fully connected defender combat behavior to `DefenderStats`:
  - Centralized attack damage calculation in `DefenderStats.get_attack_damage()`, powering projectile damage.
  - Derived firing cadence dynamically from `attack_speed` (attacks per second) via `DefenderStats.get_fire_cooldown()`.
  - Configured `DefenderPlaceholder` to immediately reflect runtime changes in `attack` and `attack_speed`.
  - Preserved existing balance (`attack = 15.0`, `attack_speed = 1.25` yielding `0.8s` fire cooldown) and gameplay loop stability without introducing GDScript errors/warnings.

## [0.1.0] - Unreleased

### Added
- Implemented modular combat stats foundation (`DefenderStats`, `EnemyStats`):
  - Created `DefenderStats` resource with configurable combat fields: `attack` (15.0), `attack_speed` (1.25), `critical_chance` (0.05), `critical_damage` (1.5), and `range` (240.0), with helper method `get_fire_cooldown()`.
  - Created `EnemyStats` resource with configurable combat fields: `max_hp` (100.0), `movement_speed` (85.0), `attack` (10.0), `attack_speed` (1.0), and `reward` (10).
  - Integrated `DefenderStats` into `DefenderPlaceholder` via `@export var stats: DefenderStats`, delegating detection range, fire cooldown calculations, and projectile damage.
  - Integrated `EnemyStats` into `EnemyPlaceholder` via `@export var stats: EnemyStats`, delegating max HP, movement speed, and coin reward amounts.
  - Preserved existing balance, combat timing, auto-targeting, and respawn gameplay loop behavior.

## [0.0.9] - Unreleased

### Added
- Completed Milestone 1 Integration & Polish:
  - Hid temporary debug visuals (path guide line, waypoint markers, detection range ring, targeting beam line, and lock-on reticle) by default for a clean gameplay presentation.
  - Consolidated debug visual rendering behind a single disabled-by-default toggle (`show_debug_visuals = false`) on `ArenaPlaceholder`, `DefenderPlaceholder`, and `EnemyPath`.
  - Refined HUD top bar kill counter with a styled container badge (`"Kill Enemies: X"`) positioned within top reserved layout boundaries.
  - Stabilized and verified the complete infinite gameplay loop: Spawn -> Path Movement -> Auto-Targeting -> Projectile Firing -> Damage Calculations -> HP Bar & Popups -> Death Dissolution -> Coin Reward -> Continuous Respawning.

## [0.0.8] - Unreleased

### Added
- Implemented kill counter and continuous enemy respawn loop (`ArenaPlaceholder`, `HUDPlaceholder`):
  - Added kill counter tracking (`kill_count`) in `ArenaPlaceholder` emitting `enemy_killed(total_kills)` signal on each enemy death.
  - Added top HUD kill counter display rendering `"Kill Enemies: 0"` dynamically updating on each kill.
  - Added modular automatic enemy respawning with configurable delay (`respawn_delay = 1.0s`) after an enemy dies.
  - Enforced single active enemy constraint (`current_enemy`) allowing continuous, seamless infinite combat testing.
  - Verified defender auto-acquisition for newly spawned enemies along the path.

## [0.0.7] - Unreleased

### Added
- Implemented enemy death and coin reward event (`EnemyPlaceholder`):
  - Added `is_dead` state flag and `_die()` handler triggered once when enemy HP reaches 0.
  - Stopped enemy movement and disabled further targeting/damage taking upon death.
  - Added temporary Godot-native primitive death dissolution visual effect (dissipating burst ring, expanding line fragments, and fading spark/shadow).
  - Configured configurable despawn delay (`death_duration = 0.6s`) before removing the enemy node (`queue_free()`).
  - Added configurable coin reward (`coin_reward = 10`) emitting `enemy_died(coins, pos)` signal.
  - Added temporary floating gold reward indicator (`+10 Coins`) floating upward and fading out at death location.
  - Updated `DefenderPlaceholder` and `ProjectilePlaceholder` to safely handle and clear dead targets.

## [0.0.6] - Unreleased

### Added
- Implemented first enemy HP and damage loop:
  - Added configurable `max_hp` (100.0) and `current_hp` tracking to `EnemyPlaceholder` with `take_damage(amount)` method.
  - Added safe HP clamping at 0.0 with enemy remaining active for testing damage behavior.
  - Added dynamically rendered enemy HP health bar above enemy head (color-shifting green -> yellow -> red based on HP %).
  - Added animated floating damage numbers (`-15`) on each projectile hit floating upward and fading out.
  - Configured projectile hit impact to inflict defender weapon damage (`damage = 15.0`).
  - Preserved existing movement, targeting, and projectile behaviors.

## [0.0.5] - Unreleased

### Added
- Implemented projectile firing foundation from defender to active target (`ProjectilePlaceholder`):
  - Created a Godot-native primitive projectile scene (`projectile_placeholder.tscn` / `projectile_placeholder.gd`) rendered as a glowing orb with core and shadow.
  - Added automatic weapon firing in `DefenderPlaceholder` with configurable cooldown interval (`fire_cooldown = 0.8s`).
  - Added homing trajectory movement towards target position.
  - Added proximity hit detection (`hit_distance = 12.0px`) that safely frees projectile upon reaching target.
  - Added automatic target validation and lifetime checks (`max_lifetime = 4.0s`) to clean up orphaned projectiles.
  - Added `Projectiles` node container to `ArenaPlaceholder` for clean projectile node lifecycle management.
  - Retained targeting debug line and lock-on reticle visuals for testing feedback.

## [0.0.4] - Unreleased

### Added
- Implemented defender auto-targeting foundation (`DefenderPlaceholder`):
  - Created a Godot-native primitive defender structure positioned on top of the central platform.
  - Added automatic target acquisition logic searching within a defined detection range (`detection_range = 240.0`).
  - Added continuous target tracking and range validation to clear targets when out of range or invalid.
  - Added visual targeting testing indicators: a targeting line/beam from the defender crystal core to the target enemy and a lock-on reticle.
  - Linked `DefenderPlaceholder` to `Enemies` container in `ArenaPlaceholder`.

## [0.0.3] - Unreleased

### Added
- Implemented first enemy movement foundation (`EnemyPlaceholder`):
  - Created a modular placeholder enemy using Godot primitives (crimson orb/diamond with core glow and shadow).
  - Defined modular path routing (`EnemyPath`) from outer framing entry point through isometric ring waypoints down to central platform.
  - Added smooth frame-by-frame movement along path waypoints, stopping automatically at central defender platform destination.
  - Added path guide visualization and waypoint markers for visual testing feedback.

## [0.0.2] - Unreleased

### Added
- Built the static battle arena visual foundation for 540x960 portrait layout.
- Added modular isometric arena components:
  - `ArenaBackground`: Deep dark battleground backdrop with ambient ground floor and grid guides.
  - `ArenaRings`: Layered isometric defense rings (outer, mid, inner) with path indicators and cardinal node markers.
  - `CentralPlatform`: Multi-tier isometric central defender/tower platform with shadow, pedestal facets, and top placement pad.
  - `ArenaFraming`: Four corner environmental framing structures and arches framing the battlefield.
- Maintained clear top HUD (0..105) and bottom skill/navigation (750..960) zones.

### Fixed
- Fixed GDScript variable type inference warnings in `arena_rings.gd` and arena visual components for strict Godot 4.7.1 compatibility.

## [0.0.1] - Unreleased

### Fixed
- Fixed scene parser error in battle and arena placeholder scenes by ensuring correct `[gd_scene]` headers.
- Fixed script parse error where scene headers were improperly placed inside `.gd` files.
