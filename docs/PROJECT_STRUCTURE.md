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
│   └── world/        # Test areas and world scenes
└── scripts/
    ├── combat/       # Weapons and damage
    ├── enemies/      # Creature behavior
    ├── environment/  # Weather and time-of-day systems
    ├── inventory/    # Items and inventory behavior
    ├── player/       # Movement and player actions
    └── survival/     # Health and survival needs
```

## Current prototype

- `scenes/world/main.tscn` is the starting test area.
- `scenes/player/player.tscn` contains the player body and camera.
- `scripts/player/player_controller.gd` handles first-person movement.

The folders are expanded as the game needs them. Keep related scenes and scripts easy to find, and avoid adding systems before a playable feature needs them. Godot's generated `.godot/` cache is ignored by Git.
