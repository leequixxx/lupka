# Lupka

> Point at a word on your screen. Get a context-aware translation. Save it for learning.

**Lupka** is a work-in-progress desktop popup translator for people learning languages from real content: games, videos, books, and whatever else happens to be on screen.

Hover over a word, press a hotkey, and Lupka uses OCR and an LLM to identify the word, restore its dictionary form, translate it in context, and save it to an open learning backlog. No copy-pasting, no switching apps, no language-specific dictionary databases.

The name comes from the informal Polish **lupka**, the diminutive of *lupa* — a magnifying glass.

[Website](https://lupka.io) · [Specification](docs/spec.md) · [Architecture decisions](docs/spec.md#architecture-decision-records)

## Design highlights

- **Works from pixels.** OCR reads the screen instead of relying on application-specific APIs, so the same mechanism applies to native apps, games, videos, VMs, and streamed content.
- **Context-aware by default.** The LLM receives the surrounding line and returns a lemma, contextual translation, part of speech, and a short note.
- **Fast before clever.** The popup targets OCR results in ≤300 ms and translation in ≤1.5 s. Model selection prioritizes latency over benchmark scores.
- **Local where possible.** OCR is on-device. Local and platform models are supported alongside user-configured cloud providers.
- **Bring your own key.** An OpenAI-compatible provider slot covers hosted and local models, with a separate Anthropic adapter and system credential storage for keys.
- **Open learning data.** Markdown and CSV sinks keep the backlog independent of any particular notes app or synchronization service.
- **Manual when needed.** Per-window `hover`, `point`, and `region` lookup modes handle unreliable cursors and busy interfaces. Card images can use an automatic word crop, a constrained manual region, or no image at all.
- **Native where it matters.** Native macOS and Windows shells sit on top of a shared Rust core.

## How it works

```text
hotkey
  → screenshot according to the per-window lookup mode
  → on-device OCR
  → target word (hover / point / region) + context line
  → LLM lemma + translation + part of speech + note
  → popup + image crop (word / region / off)
  → Markdown / CSV backlog + optional image
```

The popup appears without stealing focus. OCR results are shown immediately; the translation fills in when it arrives. In the default mode, one action saves the entry, and duplicate lemmas are detected before saving. Manual lookup and image-selection modes are available for windows that need them.

## Architecture

Lupka is designed as a shared **Rust core** with native shells:

- **macOS:** Swift, SwiftUI, AppKit, ScreenCaptureKit, and Apple Vision;
- **Windows:** C#, WinUI 3, Graphics Capture API, and WinRT OCR.

The core owns configuration, profiles, prompt templates, LLM providers, response parsing, window matching, and backlog sinks. Platform shells own hotkeys, capture, OCR, popups, credential storage, and speech. Bindings are generated with uniffi through a deliberately small, flat FFI boundary.

See [ADR-0002: Rust core and native shells](docs/adr/0002-rust-core-and-native-shells.md) for the decision and rejected alternatives.

## Documentation

- [Specification](docs/spec.md) — product overview, design principles, and the ADR index.
- [Architecture decision records](docs/spec.md#architecture-decision-records) — detailed decisions, consequences, and alternatives.
- [ADR template](docs/adr/0000-template.md) — starting point for proposing an architectural change.
- [Naming](docs/naming.md) — name rationale and availability notes.
- [Release process](RELEASING.md) — SemVer, release PRs, tags, packaging, and publication.
- [Repository infrastructure](infra/github/README.md) — OpenTofu configuration for GitHub settings and `main` protection.

## Community

- [Contributing guide](CONTRIBUTING.md) — contribution workflow, ADR rules, and validation expectations.
- [Code of Conduct](CODE_OF_CONDUCT.md) — participation and enforcement expectations.
- [Security policy](SECURITY.md) — private vulnerability reporting and sensitive-data guidance.

## Project status

Early development. The repository contains an initial Rust and macOS bootstrap, but the lookup flow is not implemented yet. There is no stable release or installation path. Expect the design and implementation to change.

Feedback, issues, and pull requests are welcome. For architectural changes, start with the [ADR template](docs/adr/0000-template.md) rather than quietly rewriting the world.

## AI slop notice

This project is heavily AI-assisted and may contain genuine AI slop. Expect sharp edges, questionable decisions, and code that needs review. Do not trust it blindly with API keys, personal files, or screen content.

## License

Lupka is available under the [MIT License](LICENSE).
