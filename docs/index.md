# notcurses — Pony TUI Bindings

Pony bindings for [notcurses](https://github.com/dankamongmen/notcurses),
a library for building terminal user interfaces.

## Getting Started

New to this library? Start with the tutorial — it walks you through building
a complete TUI application step by step.

1. [Hello World](tutorial/01-hello-world.md) — Setup, minimal app, lifecycle
2. [Planes and Layout](tutorial/02-planes-and-layout.md) — Child planes, positioning, borders
3. [Styling](tutorial/03-styling.md) — Colors, text styles, PlaneStyleBuilder
4. [Input](tutorial/04-input.md) — Keyboard, mouse, event handling
5. [Widgets](tutorial/05-widgets.md) — Selector, progress bar, reader, plot
6. [Putting It Together](tutorial/06-putting-it-together.md) — Complete application

## Concepts

Understand the design decisions and Pony-specific patterns behind the library.

- [Architecture](concepts/architecture.md) — Three-layer design, embedding, actor model
- [Planes](concepts/planes.md) — Plane hierarchy, lifecycle, sub-accessors
- [Input](concepts/input.md) — Polling, focus, InputWidget, routing
- [Rendering](concepts/rendering.md) — Double-buffer model, when to render, color systems
- [Widgets](concepts/widgets.md) — Widget lifecycle, input vs display, patterns

## API Reference

Generated from source docstrings. Build with `ponyc --docs` for the full
API reference covering all public types and methods.
