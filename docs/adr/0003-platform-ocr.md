# ADR-0003: Platform on-device OCR

- Status: Accepted
- Date: 2026-11-25

## Context

Lookup must work over games, browser video, virtual machines, and streamed windows regardless of how their content is rendered. OCR should be fast, private, and independent of network access.

## Decision

Use platform on-device OCR as the primary mechanism:

- macOS: Apple Vision with `recognitionLanguages` from the active profile, `.accurate`, and language correction enabled;
- Windows: WinRT OCR with the language pack from Windows settings.

In the default `hover` lookup mode, capture an approximately 1000×500 pt configurable area around the cursor rather than the whole screen to reduce latency and noise. `point` captures a frame for manual target selection, and `region` additionally restricts OCR to the user-selected area. All manual interactions reuse that captured frame; lookup modes are defined in ADR-0004.

For languages unsupported by Vision, fall back to Tesseract CLI, using TSV output for bounding boxes.

## Consequences

- Vision supports a finite list of languages (~20+); Tesseract broadens coverage to 100+ languages but typically takes ~300–600 ms and has lower quality on game fonts.
- Stylized fonts such as Gothic and pixel fonts degrade OCR quality. Enlarging the capture area and hovering more precisely can mitigate this, and user documentation must state the limitation honestly.
- Pixel capture works with native applications, Wine/CrossOver, VMs, and streaming.

## Alternatives considered

- **Cloud OCR such as Google Vision** — adds latency, networking, cost, and privacy exposure where on-device OCR is sufficient.
