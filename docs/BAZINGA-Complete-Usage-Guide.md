# BAZINGA Complete Usage Guide

## Quantum Self-Correcting System

The core of BAZINGA is now the quantum self-correcting system:

```bash
./bz <command> [options]
# or
./bazinga-quantum <command> [options]
```

This system automatically detects and repairs errors in scripts and provides a unified interface to all BAZINGA functionality.

## Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `visualize` | Generate framework visualization | `./bz visualize` |
| `trust` | Run trust corrector | `./bz trust --reflect "I keep trying to explain"` |
| `glance` | Get activity snapshot | `./bz glance 30` |
| `clean` | Clean temporary files | `./bz clean` |
| `claude` | Process CLD artifacts | `./bz claude` |
| `git` | Optimize git repository | `./bz git` |

## Self-Correction Features

The quantum system implements:

1. **Script repair** - Automatically fixes syntax errors in shell scripts
2. **Error logging** - Tracks all errors in system/quantum_errors.log
3. **CLD artifact management** - Preserves and catalogs CLD interactions

## Git Integration

BAZINGA is now git-ready with:

```bash
./bz git
```

This command optimizes the repository structure, focusing on core components while excluding large temporary files.

## File Structure

```
BAZINGA/
├── system/             # Core system components
├── artifacts/          # Generated artifacts including CLD outputs
├── docs/               # Documentation and guides
├── src/                # Source code
│   └── core/           # Core functionality
├── bz                  # Primary command shortcut
└── bazinga-quantum     # Self-correcting system
```

## Documentation

For more detailed information, see the following guides:

- `docs/bazinga/language/complete-doc.md` - Framework documentation
- `docs/fractal_analysis/Fractal_Numerical_Encoding_Guide.md` - Encoding guide
- `docs/bazinga/language/integration-guide.md` - Integration guide
