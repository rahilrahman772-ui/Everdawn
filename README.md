# Everdawn

> 🚧 **Under Development**

Everdawn is an open-world survival exploration game being built with **Godot 4** and **GDScript**. The goal is to explore a dangerous wilderness, survive its changing conditions, and prepare for encounters with hostile creatures.

## Vision

The planned experience brings together:

- **Exploration:** travel through a large wilderness and discover places, resources, and points of interest.
- **Survival:** manage needs such as health, stamina, hunger, and thirst.
- **Hostile creatures:** encounter wildlife and other threats with readable behavior.
- **Weapons and combat:** craft and use tools and weapons to defend yourself.
- **Crafting:** gather materials and turn them into useful equipment and supplies.
- **Environmental systems:** build toward changing weather and a day-and-night cycle.

These are project goals, not claims about features already implemented.

## Current prototype

The first playable foundation is in place:

- A small 3D outdoor test area.
- A first-person player with mouse look, walking, sprinting, and jumping.
- Controls: **WASD** to move, **Shift** to sprint, **Space** to jump, and **Escape** to release the mouse.

The prototype uses simple placeholder shapes and colors. Survival needs, creatures, crafting, weapons, and a larger world remain planned work.

## Technology

- **Engine:** Godot 4
- **Main language:** GDScript
- **Possible later option:** C++ with GDExtension if a measured performance need calls for it
- **Version control:** Git and GitHub

The project starts with GDScript. Native extensions are not required to begin development.

## Repository layout

```text
Everdawn/
├── README.md
├── .gitignore
├── docs/
│   └── PROJECT_STRUCTURE.md
└── project/
    ├── project.godot
    ├── assets/
    ├── scenes/
    │   ├── player/player.tscn
    │   └── world/main.tscn
    └── scripts/
        └── player/player_controller.gd
```

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for what belongs in each area.

## Getting started

1. Install Godot 4.
2. Clone this repository.
3. In Godot's Project Manager, import the project by selecting `project/project.godot`.
4. Run the project with **F6** or the play button after the project is imported.

## License

No license has been selected yet. Until one is added, the code and other original project materials remain under the copyright of their respective authors; public visibility alone does not grant permission to reuse them.
