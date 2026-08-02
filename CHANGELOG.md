# Changelog

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
  - Created a modular placeholder enemy using Godot primitives (crimson orb/diamond with core glow and ground shadow).
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
