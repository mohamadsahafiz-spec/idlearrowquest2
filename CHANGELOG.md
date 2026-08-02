# Changelog

## [0.7.7] - Unreleased

### Added
- **Individual Maid Combat Foundation**: Each active Maid owns an independent runtime combat profile (HP, Attack, Speed, Critical) while preserving Liria's player progression.
- **Combat Role Architecture**: Generic combat role foundation supporting RANGED, MELEE, MAGIC, and SUPPORT definitions with targeting preferences, range, and skill hooks.
- **Per-Maid Equipment Ownership**: Per-Maid equipment slot tracking (Weapon, Armor, Ring, Boots) with independent equipment stat calculations per Maid.
- **Individual Defeat & Recovery**: Maids fall independently upon HP depletion; battle continues until all active party members fall.
- **Combat Contribution Tracking**: Real-time per-Maid tracking for damage dealt, kills, critical hits, and deaths with query API hooks.

## [0.7.6] - Unreleased

### Added
- **Visible In-Game DEV Panel**: Added a clickable top-bar `[DEV]` button opening a developer suite modal UI.
- **Party Test Controls**: Added `[1]` to `[6]` party size overrides, Heal All, Kill Maid, and Kill All debug actions.
- **World & Boss Test Overrides**: World select buttons (W1–W6), stage jump controls, force boss trigger, stage/world instant clear, and endless mode toggle.
- **Economy & Combat Testing**: Gold adjusters (+10K, +1M, Set 0, Set 100K), upgrade resets, and fresh baseline initialization.
- **Safe Reset & Isolation**: Added temporary test run reset and permanent save deletion with confirmation guard.

## [0.7.5] - Unreleased

### Added
- **Multi-Maid Combat Spawning**: Dynamic spawning for 1–6 active Maids in combat with backward compatibility for Liria (#001) and safe base combat profiles for #002–#006.
- **Independent Maid Combat**: Each active Maid independently acquires targets, fires projectiles, deals damage, and participates in boss fights through the combat pipeline.
- **Party Formation Offsets**: Centralized formation positioning for party sizes 1–6 adapting smoothly without overlapping.
- **Party Defeat Condition & Debug Controls**: Updated defeat logic requiring all active Maids to fall before triggering defeat, and added shift-key shortcuts (`Shift+1..6`) for dev testing.

## [0.7.4] - Unreleased

### Added
- **Battle Maid Registry & Roster**: Added `MaidRegistry` supporting 6 Battle Maid slots (#001 Liria unlocked by default, #002-#006 as locked placeholders).
- **Recruitment & Party Management**: Modular recruitment system and 1-6 slot party manager with validation against duplicate/locked assignments and reordering.
- **Save Migration & Maid Progression Foundation**: Persisted unlocked maids, recruitment state, and 1-6 party composition with automatic default migration for legacy save files.

## [0.7.3] - Unreleased

### Added
- **Six-World Registry**: Centralized data-driven `WorldRegistry` registering Royal Kingdom (10), Enchanted Forest (30), Frozen Kingdom (60), Gothic Realm (100), Infernal Realm (250), and Celestial Realm (500).
- **World Progression Core**: Clean campaign progression flow between worlds with world unlock, stage resets, and Endless Mode trigger upon clearing Celestial Realm Stage 500.
- **Save State Persistence**: Multi-world save state recording current world, highest unlocked world, completed worlds, and endless mode, with backwards-compatible loading defaults.

## [0.7.2] - Unreleased

### Added
- **World 1 Royal Kingdom Stage Structure**: 10 total stages divided into 4 stage environment groups (Royal Outskirts 1-3, Kingdom Road 4-6, Damaged Village 7-9, Royal Castle Front 10).
- **World 1 Enemy Roster & Boss Progression**: Data-driven enemy identities per stage group, and 3 distinct progression boss encounters (Goblin Captain at Stage 5, Orc Warlord at Stage 8, Young Crimson Dragon at Stage 10).
- **World Completion Foundation**: Victory at Stage 10 completes Royal Kingdom, prevents stage 11 overflow, emits world_completed hook, and persists completion state in SaveSystem.

## [0.7.1] - Unreleased

### Added
- **Maid #001 — Liria Visual Layer**: Replaced defender placeholder visuals with a custom vector chibi presentation layer for Liria (silver hair, violet eyes, rookie maid dress, starter bow + quiver).
- **Procedural Animations & Bow Launch**: Idle breathing bob, attack recoil/string pull aiming at targets, hit reaction flash, defeat pose, and projectile origin aligned with bow string.

## [0.7.0] - Unreleased

### Added
- **WorldPresentation Architecture**: Modular World 1: Royal Kingdom foundation with stage environment variants (Royal Outskirts, Kingdom Road, Damaged Village, Royal Castle Front) and theme accents.
- **Decoupled Visual Hooks**: Created presentation layer hooks in Defender, Enemy, and Boss components to allow custom visual/VFX replacements without affecting combat calculations or stats.

## [0.6.0] - Unreleased

### Added
- **SaveSystem & Local Persistence**: Periodically auto-saves game state (Stage, Gold, Upgrades, Inventory, Equipment, AUTO settings) to local JSON and restores on launch.
- **Offline Rewards & Welcome Back**: Calculates mathematical gold and equipment rewards for offline time (up to 8h max), granted upon CLAIM in Welcome Back modal.
- **Auto Upgrade & Auto Equip**: Master toggles for automatic gold spending on balanced upgrades and auto-equipping power-improving gear.
- **Idle Status & Debug Controls**: Compact HUD status showing AUTO SKILLS, AUTO UPGRADE, AUTO EQUIP states with debug buttons for offline simulation testing.

## [0.5.1] - Unreleased

### Added
- **Skill Visual Effects**: Visible meteor strike animation with impact flash and shockwave ring; frost overlay with radiating ice spikes on frozen enemies; electric aura pulse on defender during Overdrive.
- **Stage State Auto Cleanup**: Replaced invalid StageSystem property references with `stage_system.state` checks (`WAVE_ACTIVE` / `BOSS_ACTIVE`), preventing AUTO skills during victory/defeat/transitions.

## [0.5.0] - Unreleased

### Added
- **SkillSystem Foundation**: Centralized active skills engine (`scenes/battle/skill_system.gd`).
- **Meteor**: Trigger high AoE damage to active enemies (supports crits based on defender stats, 30s cooldown).
- **Freeze**: Freeze active enemies for 5s, stopping movement and attacks, resuming normally afterward (25s cooldown).
- **Overdrive**: Boost effective attack speed by +100% for 8s, stacking with progression/equipment and restoring exact speed afterward (30s cooldown).
- **Skill HUD**: 3 skill cards displaying READY/ACTIVE/cooldown states and countdowns without obstructing upgrade UI.
- **Auto Skills**: Independent AUTO ON/OFF toggles per skill persisting across stages during run, safe during victory/defeat transitions.

## [0.4.1] - Unreleased

### Added
- **Item Power & Stage Scaling**: Equipment items roll item level based on dropped stage with centralized scaling formulas.
- **Smart Stat Rolls**: Tailored stat biases per slot (Weapon: ATK/CRIT, Armor: HP/ATK, Ring: ATK/CRIT, Boots: SPD/HP).
- **Stat Comparison**: Added simple `+` / `-` delta comparison when viewing inventory items vs currently equipped gear.
- **Auto-Equip ("Equip Best")**: Added button in inventory overlay to evaluate and equip optimal gear combination.
- **Combat Power (PWR)**: Added centralized combat power calculation displayed dynamically in HUD stats panel.
- **Loot Scaling**: Enemy tiers (Strong/Elite/Boss) and stages scale drop rarity odds and item power while preserving infinite progression.

## [0.4.0] - Unreleased

### Fixed
- Fixed bug where non-HP upgrades reset Defender Max HP to default 100.
- `ProgressionSystem` now captures and preserves configured `DefenderStats` base stats.
- `restore_base_stats()` on `DefenderPlaceholder` now correctly resets stats to initial configured base values upon restart.

### Added
- Implemented Equipment + Loot Foundation:
  - **Infinite Progression**:
    - Removed upgrade level caps for Attack Speed and Critical Chance.
    - Attack and Max HP scale indefinitely.
    - Attack Speed applies diminishing returns formula at higher levels for smooth performance.
    - Critical Chance supports overflow beyond 100% for multi-crit damage calculation.
  - **Equipment System & Slots**:
    - Introduced 4 equipment slots: `WEAPON`, `ARMOR`, `RING`, and `BOOTS`.
    - Created modular `EquipmentItem` class and `EquipmentSystem` handling stats, inventories, and equipping/unequipping.
  - **5 Equipment Rarities**:
    - Defined `COMMON`, `RARE`, `EPIC`, `LEGENDARY`, and `MYTHIC` rarities with unique color styling and stat scaling.
  - **Loot Drops & Boss Guarantee**:
    - Enemy kills roll equipment loot drops scaling with tier (`Normal`, `Strong`, `Elite`, `Boss`).
    - Bosses guarantee at least 1 Epic+ equipment drop.
    - Rendered animated top toast notification displaying item rarity, slot, and name upon loot drop.
  - **Inventory & Equip UI**:
    - Added dedicated Inventory Overlay Panel toggled via top `EQUIP / BAG` HUD badge.
    - Rendered equipped gear slots with unequip buttons and item stats preview.
    - Interactive inventory list rows allowing players to equip/replace items with instant stat recalculation stacking with upgrades.
  - **Loot Testing Controls**:
    - Added inspector debug controls `debug_force_loot_drop` and `debug_force_rarity` (default OFF).

## [0.3.1] - Unreleased

### Added
- Implemented Progression Expansion:
  - **Defender Max HP Upgrade**:
    - Added Defender Max HP upgrade with cost and stat formulas centralized in `ProgressionSystem`.
    - Purchasing Max HP upgrade instantly increases both Max HP and current HP by the gained amount.
  - **Defender HP HUD**:
    - Rendered dedicated Defender HP bar with live HP / Max HP numbers and color-shifting health fill bar.
  - **Economy Scaling**:
    - Scaled enemy Gold rewards modestly by Stage level (`Stage 1 Normal = 10`, `Stage 2 Normal = 15`, `Boss = 200+`).
  - **Upgrade Balancing & Caps**:
    - Centralized progression formulas for Attack, Attack Speed, Critical Chance, and Max HP in `ProgressionSystem`.
    - Applied caps to Attack Speed (4.0/s) and Critical Chance (80%).
  - **Combat Stats Display**:
    - Rendered compact real-time combat stats panel displaying `ATK`, `SPD`, `CRIT`, and `HP`.
  - **Defeat & Restart Flow**:
    - Added Defender death detection emitting `defender_died` and `hp_changed` signals.
    - Added `DEFEAT` overlay state with `"Defender Destroyed"` subtitle and interactive `"RESTART RUN"` button.
    - Restarting run resets Stage, waves, enemy spawns, run Gold, and upgrade levels to Stage 1 base values.

## [0.3.0] - Unreleased

### Added
- Implemented Core Progression & In-Run Upgrades:
  - **Persistent Run Gold**:
    - Earned Gold directly from enemy rewards upon kill (Normal, Strong, Elite, Boss).
    - Displayed real-time Gold balance badge in top HUD header bar.
  - **Attack Upgrade System**:
    - Incremented Defender attack level (starts Lv.1) with +3.0 attack power per level.
    - Displayed current → next value and escalating Gold cost in upgrade UI.
  - **Attack Speed Upgrade System**:
    - Incremented Defender attack speed level with +0.10 attacks/sec per level.
    - Updated fire cooldown rate dynamically in combat pipeline.
  - **Critical Chance Upgrade System**:
    - Incremented Defender critical hit chance with +2% crit chance per level.
    - Retained existing damage multiplier pipeline for critical hits.
  - **Upgrade HUD Panel**:
    - Added bottom upgrade UI panel featuring Attack, Attack Speed, and Critical cards with interactive click/touch upgrade buttons.
    - Visual affordance state: highlighted active state when affordable, dimmed/locked state when Gold is insufficient.
  - **Run Progression Persistence**:
    - Upgrades and Gold persist seamlessly across stage transitions.

## [0.2.1] - Unreleased

### Added
- Implemented Boss Fight, Victory Transition & Stage Progression:
  - **Boss Fight Execution**:
    - Triggered Boss fight transition after completing Wave 3 ("BOSS INCOMING" -> spawn Boss).
    - Restricted spawning during Boss fight to exactly one Boss enemy (no regular enemies).
    - Reused existing Boss stats and shared combat pipeline.
  - **Boss HUD Display**:
    - Rendered top Boss HUD bar displaying Boss name/tier (`STAGE X BOSS`), current HP, max HP, and progress fill bar when Boss is active.
    - Automatically hid Boss HUD upon Boss death.
  - **Stage Completion & Victory Overlay**:
    - Triggered `STAGE COMPLETE` state upon Boss death, pausing enemy spawning.
    - Functional victory overlay displaying `VICTORY` heading and `Stage X Complete` subtitle.
  - **Next Stage Progression**:
    - Automatically advanced to Stage 2 after victory overlay transition.
    - Reset wave counters to Stage 2, Wave 1 / 3, Enemies 0 / 5.
    - Applied modest enemy stat scaling (HP, attack, rewards) for Stage 2 through `StageSystem`.
    - Maintained continuous kill count, rewards, and combat counters across stage transitions.

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
- Resolved GDScript class resolution conflicts in `arena_placeholder.gd` and `battle.gd` by using direct global `StageSystem` class reference instead of script preloading.

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
