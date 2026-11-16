# Exdot

Exdot is an experimental programming language and Godot plugin focused on stricter, more explicit code while keeping a familiar syntax inspired by GDScript.
The project started as an attempt to make GDScript stricter, but has since grown into its own language with custom syntax, compile-time analysis, editor integration, and a dedicated compilation pipeline.
Exdot is currently in early development and is not ready for production use.

## Goals

Exdot aims to provide:
- Stronger type safety
- Explicit behavior instead of hidden runtime magic
- Clearer references and ownership
- Better compile-time diagnostics
- Tight integration with the Godot editor
- A syntax that remains familiar to GDScript users
- A compiler architecture that can optimize and transform code before generating runtime output

## Example

```exdot
using { Input }

readonly export var speed: Float = 5.0
node Player := <CharacterBody3D>

on ready() -> Void:
	print("Player ready")

on physics_process(delta: Float) -> Void:
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	if direction == Vector2.ZERO:
		return

	if Player is CharacterBody3D:
		Player.velocity.x = direction.x * speed
		Player.velocity.z = direction.y * speed
		Player.move_and_slide()
```

## Current Features

Exdot already explores concepts such as:
- Static and inferred types
- `readonly` variables
- Exported variables, functions, and types
- Union types
- Interfaces
- Runtime type checks and conversion with `as`
- Type checks and narrowing with `is`
- Pattern/value checks with `matches`
- Explicit reference parameters using `*`
- Lifecycle handlers using `on`
- Editor-bound Node references
- Godot API imports through `using`
- Custom compiler and tokenizer infrastructure
- Godot Script Editor integration
- Custom syntax highlighting

Many of these features are still evolving and may change.

## Project Status
Exdot is currently highly experimental.
Syntax, compiler behavior, APIs, and project structure may change without notice. The current focus is on defining the language, building the compiler frontend, and improving editor integration.

## Documentation
More detailed documentation will be available in the GitHub Wiki.
The Wiki will cover language syntax, type rules, functions, Node bindings, lifecycle events, Godot integration, compiler behavior, and other Exdot-specific concepts.

## Contributing
Contributions, bug reports, and suggestions are welcome.
For larger changes, please open an issue or discussion first so the idea can be aligned with the current direction of the project.

See [CONTRIBUTING.md](docs/CONTRIBUTION.md) for more information.

## License
See the [repository license](LICENSE) for details on how this project may be used.
