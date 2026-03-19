# Realtime Particle System in TouchDesigner

A GPU-based particle system built in TouchDesigner using GLSL compute shaders.

Each particle follows a birth-life-death lifecycle driven by an age counter.
At birth, particles are assigned random "genes" (size, color seed, lifespan)
that shape their behaviour throughout their lifetime. Movement is computed
per-frame using Newtonian mechanics (forces, acceleration, velocity, position),
and color transitions from a start to end color with an alpha envelope that
includes a flash effect at birth and decay at death. All particle state is
managed on the GPU via compute shader buffers.

![Preview](preview.gif)

## Requirements

- TouchDesigner 2023.11760 (or later)
- GPU with OpenGL 4.3+ support

## Usage

### Open full project (final render)

Open `ParticleSystem.toe` in TouchDesigner.

### Import component

Drag `tox/ParticleSystem.tox` into any TouchDesigner project to use the particle system as a standalone module.

<!-- ## Parameters

Document the key uniforms here — the ones someone would tweak
when using the tox. Group them the same way you did in your notes:
Lifecycle, Physics, Visuals.

## Design

Link to or summarize the architecture: the state machine,
attribute types (dynamic vs static), the gene system.
Your PDF and handwritten notes are a great basis for this. -->

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