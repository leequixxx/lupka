# ADR-0003: Platform on-device OCR

- Status: Accepted
- Date: 2026-11-25

## Context

Lookup must work over games, browser video, virtual machines, and streamed windows regardless of how their content is rendered. OCR should be fast, private, and independent of network access.

## Decision

Use platform on-device OCR as the primary mechanism:

- macOS: Apple Vision with `recognitionLanguages` from the active profile, `.accurate`, and language correction enabled;
- Windows: WinRT OCR with the language pack from Windows settings.

In every lookup mode, capture every display allowed by configuration to avoid truncating context at capture-region or display boundaries. Configuration can exclude specific display IDs; all displays are included by default. Each display is captured as a separate full-resolution frame, avoiding a single stitched desktop image and preserving explicit per-display coordinates. `point` and `region` use the same multi-display frame set, with `region` additionally restricting OCR to the user-selected area. All manual interactions reuse the original captured frames.

For languages unsupported by Vision, fall back to Tesseract CLI, using TSV output for bounding boxes.

## Consequences

- Vision supports a finite list of languages (~20+); Tesseract broadens coverage to 100+ languages but typically takes ~300–600 ms and has lower quality on game fonts.
- Capturing and processing multiple displays uses more memory and can increase OCR latency. Display exclusions and separate per-display processing keep this cost controllable.
- Stylized fonts such as Gothic and pixel fonts degrade OCR quality, and user documentation must state the limitation honestly.
- Pixel capture works with native applications, Wine/CrossOver, VMs, and streaming.

## Alternatives considered

- **Cloud OCR such as Google Vision** — adds latency, networking, cost, and privacy exposure where on-device OCR is sufficient.
