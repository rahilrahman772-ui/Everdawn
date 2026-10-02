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

These are project goals, not claims about features already implemented. Everdawn is at the early setup stage.

## Technology

- **Engine:** Godot 4
- **Main language:** GDScript
- **Possible later option:** C++ with GDExtension if a measured performance need calls for it
- **Version control:** Git and GitHub

The project starts with GDScript. Native extensions are not required to begin development.

## Project status

The repository currently contains the initial project documentation and folder layout. A runnable Godot project has **not** been created yet. The next step is to create the Godot project in the `project/` folder using the Godot Project Manager.

## Repository layout

```text
Everdawn/
├── README.md
├── .gitignore
├── docs/
│   └── PROJECT_STRUCTURE.md
└── project/                 # Godot project will be created here
    ├── assets/
    │   ├── audio/
    │   ├── materials/
    │   ├── models/
    │   └── textures/
    ├── scenes/
    │   ├── enemies/
    │   ├── player/
    │   ├── ui/
    │   └── world/
    └── scripts/
        ├── combat/
        ├── enemies/
        ├── environment/
        ├── inventory/
        ├── player/
        └── survival/
```

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for what belongs in each area.

## Getting started

1. Install **Godot 4**.
2. Clone or download this repository.
3. In Godot's Project Manager, create a project in the repository's `project/` folder.
4. Keep the renderer and other project settings at their defaults for now.
5. Open the project and begin with a small playable prototype before expanding the world.

Until step 3 is complete, this repository is a documented scaffold rather than a runnable game.

## Development approach

Everdawn will be built in small, understandable steps. Early work should establish a playable character and a small test area before expanding into survival systems, creatures, crafting, and larger environments.

## License

No license has been selected yet. Until one is added, the code and other original project materials remain under the copyright of their respective authors; public visibility alone does not grant permission to reuse them.
