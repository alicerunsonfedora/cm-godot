# Contribution Guidelines

## Commit syntax

```
:gitmoji: Summary of action

Additional description. Can include details of what exactly was done, what any issues were,
and why the particular action was done. Warnings about potential issues can also go here.
```

More details on Gitmoji can be found at https://gitmoji.dev.

## GDScript code style

- Always declare types when possible, including in function signatures.

Example:

```gdscript
func _ready() -> void:
    # Write code here.
```

- Write basic documentation for **public-facing** methods.
- Code order should be as follows:
    - Class declaration
    - Exported variables
    - Signals
    - Public vars
    - Private vars (prefixed with _)
    - Init methods
    - Public methods, alphabetically
    - Private methods, alphabetically
    
## Other guidelines

- Do not fuck with Chelsea.
