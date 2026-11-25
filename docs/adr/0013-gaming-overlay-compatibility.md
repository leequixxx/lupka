# ADR-0013: Gaming overlay compatibility

- Status: Accepted
- Date: 2026-11-25

## Context

The popup is an overlay above another application. Display mode affects whether the operating system allows that overlay.

## Decision

Require games to use borderless or windowed fullscreen. Do not support exclusive fullscreen because it prevents overlays on both macOS and Windows.

## Consequences

- Users may need to change a game’s display mode before lookup can work.
- Exclusive fullscreen is an explicit compatibility limitation rather than an application bug.
