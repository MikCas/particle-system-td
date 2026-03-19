# Particle System — TouchDesigner

A GPU-based particle system built in TouchDesigner using GLSL compute shaders.

![Preview](preview.gif)

## Requirements

- TouchDesigner 2023.11760 (or later)
- GPU with OpenGL 4.3+ support

## Usage

### Open full project (final render)

Open `ParticleSystem.toe` in TouchDesigner.

### Import component

Drag `tox/ParticleSystem.tox` into any TouchDesigner project to use the particle system as a standalone module.

## Project Structure

```
├── ParticleSystem.toe      # full runnable project
├── src/
│   └── glsl/               # externalized GLSL shaders
│       ├── init.glsl        # particle initialization
│       ├── behaviour.glsl   # particle movement and forces
│       ├── particle.glsl    # particle data structures
│       ├── main.glsl        # main compute shader
│       ├── random.glsl      # RNG utilities
│       └── utils.glsl       # shared helper functions
└── tox/
    └── ParticleSystem.tox   # importable component
```

All GLSL shaders are externalized in `src/glsl/` and referenced by the `.toe` via relative paths.

## License

MIT