# Necro Telemetry Project
## Structure

```text
scripts/
├── autoloads/
│   ├── game_flow.gd
│   └── capability_registry.gd
├── player/
│   └── player_controller.gd
├── enemies/
│   └── enemy_squad.gd
└── buildings/
    └── bone_forge.gd
```

## Scripts

### `scripts/autoloads/`

Global services available throughout the game.

- **`game_flow.gd`**  
  Controls the global game phase: boot, night, siege, resurrection, and results.

- **`capability_registry.gd`**  
  Tracks gameplay capabilities provided by active buildings, such as Bone Bolt being supplied by the Bone Forge.

### `scripts/player/`

Player-related logic.

- **`player_controller.gd`**  
  Handles Necrolord movement and player input.

### `scripts/enemies/`

Enemy and squad behavior.

- **`enemy_squad.gd`**  
  Controls squad movement, targeting, combat, and shared health.

### `scripts/buildings/`

Building-specific gameplay logic.

- **`bone_forge.gd`**  
  Registers and removes the Bone Bolt capability depending on whether the Forge is operational.
