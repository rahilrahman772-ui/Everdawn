# Project structure

The layout below is a starting point for the Godot project. The folders are placeholders until gameplay files are added. Create the Godot project itself in `project/`; its `project.godot` file will live there.

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

## A few conventions

- Keep a scene and its closely related script near each other when that makes the feature easier to understand.
- Use clear names that describe what a file does, such as `player_controller.gd`.
- Put reusable art and audio in `assets/`; keep scene-specific resources with their scene when appropriate.
- Avoid adding a system before there is a small playable need for it.
- Let Godot generate its project cache. The `.godot/` directory is ignored by Git and should not be committed.
