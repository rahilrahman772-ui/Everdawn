# Project structure

The Godot project lives in `project/`; its `project.godot` file is at that folder's root.

```text
project/
├── assets/
│   ├── audio/        # Music, ambience, and sound effects
│   ├── materials/    # Reusable materials and shaders
│   ├── models/       # 3D models and animations
│   └── textures/     # Texture images
├── scenes/
│   ├── enemies/      # Creature scenes
│   ├── player/       # Player and equipment scenes
│   ├── ui/           # Menus and in-game interface
│   └── world/        # Test areas, pickups, and world scenes
└── scripts/
    ├── combat/       # Weapons and damage
    ├── enemies/      # Creature behavior
    ├── environment/  # Weather and time-of-day systems
    ├── inventory/    # Items and inventory behavior
    ├── player/       # Movement and player actions
    ├── survival/     # Health, stamina, hunger, and thirst
    └── world/        # World interactions and pickups
```

## Current prototype

- `scenes/world/main.tscn` is the starting test area and places the food and water pickups.
- `scenes/player/player.tscn` contains the player body, camera, survival components, interaction area, and HUD.
- `scenes/ui/game_hud.tscn` displays stamina, hunger, thirst, and the nearby pickup prompt.
- `scripts/player/player_controller.gd` handles third-person movement, sprinting, and pressing **E** to collect a nearby pickup.
- `scripts/survival/stamina.gd` manages sprint drain and recovery.
- `scripts/survival/vital_needs.gd` drains hunger and thirst over time and restores them when a pickup is collected.
- `scripts/world/resource_pickup.gd` applies a food or water pickup to the matching need.

The folders are expanded as the game needs them. Keep related scenes and scripts easy to find. Godot's generated `.godot/` cache is ignored by Git.
