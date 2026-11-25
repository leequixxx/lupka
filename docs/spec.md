# Lupka — specification

Lupka is a popup app for contextual language learning: hover over a word on screen → hotkey → popup with an LLM translation in context → one action, and the word is in the learning backlog.

Architecture decisions are recorded as individual ADRs. Each ADR covers one decision area, including its context, chosen solution, consequences, and relevant alternatives.

- Status: draft v1, revised 2026-11-26
- Name and availability check: [Lupka](naming.md)
- ADR template: [ADR-0000](adr/0000-template.md)

## Principles

1. **OCR on pixels, not app APIs** — universality matters more than elegance.
2. **LLMs instead of dictionary databases** — any language at no extra cost.
3. **On-device first** — OCR is always local; the cloud is only for translation and only with the user’s key.
4. **Latency > intelligence** — a popup is an instant gesture.
5. **The backlog is open text** — no closed formats between the app and learning.
6. **Every configuration level uses inheritance** — default → profile → registry preset → local patch → window; empty means inherited.

## Architecture decision records

1. [ADR-0001: Lookup pipeline and latency budget](adr/0001-lookup-pipeline.md)
2. [ADR-0002: Rust core and native shells](adr/0002-rust-core-and-native-shells.md)
3. [ADR-0003: Platform on-device OCR](adr/0003-platform-ocr.md)
4. [ADR-0004: Word hit testing and context extraction](adr/0004-hit-testing-and-context.md)
5. [ADR-0005: LLM-based lemmatization](adr/0005-llm-lemmatization.md)
6. [ADR-0006: Window identification through a matcher cascade](adr/0006-window-identification.md)
7. [ADR-0007: Language profiles](adr/0007-language-profiles.md)
8. [ADR-0008: Window overrides and semi-strict prompts](adr/0008-window-overrides-and-prompts.md)
9. [ADR-0009: LLM providers and model selection](adr/0009-llm-providers.md)
10. [ADR-0010: LLM response contract and lenient parsing](adr/0010-llm-response-contract.md)
11. [ADR-0011: Popup interaction and state model](adr/0011-popup-ux.md)
12. [ADR-0012: Backlog storage through sink providers](adr/0012-sink-providers.md)
13. [ADR-0013: Gaming overlay compatibility](adr/0013-gaming-overlay-compatibility.md)
14. [ADR-0014: Process pause and stop-frame mode](adr/0014-process-pause-stop-frame.md)
15. [ADR-0015: Federated preset registry](adr/0015-federated-preset-registry.md)
