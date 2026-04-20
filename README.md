# 🐢 TMNT: Modern Version

A high-performance **Teenage Mutant Ninja Turtles Beat-em-Up** prototype blending modern game mechanics with a custom AI-driven backend automation stack.

## 🚀 Tech Stack

* **Game Engine:** [Godot 4.3](https://godotengine.org) (GDScript)
* **Build Automation:** Python 3.12 (managed via `uv`)
* **Containerization:** Docker (`barichello/godot-ci:4.3`) for headless export pipelines.

## 🎮 Engine Architecture

This project is built from the ground up for responsiveness and modern action-platformer comfort:
- **Custom FSM (Finite State Machine):** Clean, decoupled `PlayerState` logic managing `Idle`, `Run`, `Jump`, and `Fall` states natively outside the Physics loop.
- **Micro-Mechanics:** Built-in coyote time, jump buffering, and variable jump height (`cut_jump_multiplier`).
- **2.5D Movement:** Custom lane depth integration mapping real-time `Y-Axis` input to Z-space depth in traditional arcade brawler format.
- **Global Event Bus:** Singeltons (`GameManager`, `InputReader`) heavily leaning into decoupled Signal patterns.

## 💻 Developer Setup (MacOS)

You do **not** need to use the editor to run the game! Follow the Pro CLI Workflow:

### Prerequisites
- Python 3.12 & [uv](https://github.com/astral-sh/uv)
- Godot 4.3 installed at `/Applications/Godot.app`

### Running the Project

Run directly from the repository root utilizing Godot's headless CLI flag:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path tmnt-beat-em-up
```

*Note: Headless CI workflows are available for build generation via Docker.*
