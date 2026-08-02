# Changelog

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
