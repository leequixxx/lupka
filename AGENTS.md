# Lupka agent guide

## Project overview

Lupka is a desktop popup translator for language learning from games, video, books, and other on-screen content. A hotkey captures text around the cursor, OCR identifies the word and context, an LLM returns its lemma and contextual translation, and the result can be saved to an open learning backlog.

## Language

Use English for all repository content and collaboration, including documentation, code comments, commit messages, issues, pull requests, and agent notes. Language-specific prompt values, translations, and learning content remain in their intended languages.

## Repository state

- The repository contains an initial Rust workspace and macOS Swift package bootstrap. Lookup features are not implemented yet.
- Canonical build, test, lint, and run commands are documented below. There is no stable release or installation path yet.
- Keep `README.md` and other documentation honest about what exists. Do not describe designed behavior as implemented behavior.

Key files:

- `Cargo.toml` — Rust workspace manifest.
- `Makefile` — canonical development commands.
- `crates/core/` — shared Rust core and uniffi contract.
- `crates/uniffi-bindgen/` — pinned Swift binding generator.
- `shells/macos/` — native macOS Swift package and FFI tests.
- `README.md` — public project introduction.
- `docs/spec.md` — product overview, principles, and ADR index.
- `docs/adr/` — architecture decision records.
- `docs/adr/0000-template.md` — template for new decisions.
- `docs/naming.md` — name rationale and availability notes.
- `CONTRIBUTING.md` — contributor workflow and validation expectations.
- `RELEASING.md` — SemVer, release PRs, tags, packaging, and publication.
- `SECURITY.md` — private vulnerability reporting and sensitive-data guidance.
- `CODE_OF_CONDUCT.md` — community participation expectations.
- `LICENSE` — MIT License.
- `infra/github/` — OpenTofu configuration for repository and `main` branch settings.

## Development commands

Run commands from the repository root:

- `make bindings` — build the Rust core and regenerate the committed macOS Swift bindings.
- `make build` — build the Rust workspace and macOS Swift package.
- `make test` — run Rust tests and the macOS Swift FFI test.
- `make lint` — check Rust formatting and run Clippy with warnings denied.
- `make docs` — validate local Markdown links, ADR consistency, and issue-form YAML.
- `make infra` — format-check, initialize, and validate the OpenTofu configuration without application secrets.
- `make run` — run the macOS bootstrap executable.
- `make fmt` — format Rust sources.

The current commands require macOS 13 or newer, the stable Rust toolchain from `rust-toolchain.toml`, and Apple Swift Command Line Tools; full Xcode is not required. Do not edit files in `shells/macos/Sources/LupkaCore/Generated/` or the generated files in `shells/macos/Sources/LupkaCoreFFI/` manually.

## Development workflow

Follow `CONTRIBUTING.md` for the complete process. The non-negotiable rules for agents are:

- Work on one GitHub issue, one branch, one pull request, and one resulting squash commit at a time.
- Use `123-short-slug` for branches, `feat(#123): ...` for development commits, and `#123: ...` for PR and squash titles.
- Include `Closes #123` in the PR body. Use the issue number, not the automatically suggested PR number. For release PRs, use `Refs #123` and follow `RELEASING.md` so the release issue stays open until publication.
- Do not push directly to `main` or reuse a branch after a squash merge. Never reuse, move, or overwrite a published release tag.
- After work has merged, use a new linked issue for fixes or follow-up scope rather than reopening the merged issue.
- Parallel agents use separate worktrees and separate issues. Assign new ADR numbers in the issue and re-read the current file tree before creating files.
- Run the required checks and update affected documentation and ADRs before requesting review.

## Repository infrastructure

- Manage GitHub repository settings through `infra/github/`; do not apply unreviewed changes.
- Follow `infra/github/README.md` for import, planning, and maintainer-controlled apply.
- Validate changes with `cd infra/github && tofu fmt -check && tofu validate` after provider initialization.
- Never commit Terraform state, plans, provider caches, GitHub tokens, or signing credentials.

## Architecture boundaries

- Keep shared business logic in the Rust core and platform integration in native shells.
- macOS uses Swift/SwiftUI with AppKit where needed; Windows uses C#/WinUI 3.
- The core owns configuration, profiles, prompts, LLM providers, response parsing, window matching, and backlog sinks.
- Shells own hotkeys, screen capture, OCR, popups, credential storage, speech, and process suspension.
- Keep the uniffi FFI boundary flat and simple: data structures and strings, no callbacks or shared ownership.
- Use pixel-based, on-device OCR rather than application-specific text APIs.
- Keep backlog storage open and application-independent through Markdown/CSV sinks; do not couple it to a particular notes app.
- Configuration inherits through `default → profile → registry preset → local patch → window`; empty fields inherit.

Read the relevant ADR before changing an established decision, especially `docs/adr/0002-rust-core-and-native-shells.md`.

## Documentation and ADRs

- Keep `docs/spec.md` as an overview and index rather than duplicating complete ADR content.
- Record one decision per ADR using `docs/adr/0000-template.md`.
- Use contiguous `NNNN-kebab-case.md` filenames and matching `# ADR-NNNN: Title` headings.
- Do not create a second ADR for an existing decision. Clarify the current ADR when needed; create a superseding ADR when replacing a decision.
- Add every new ADR to `docs/spec.md` and update affected cross-references.
- Keep documentation focused on current product and technical decisions, not personal circumstances, business plans, or roadmap commentary.

## Privacy and safety

- Store API keys in macOS Keychain or Windows Credential Manager, never in plaintext configuration.
- Do not add telemetry or silent uploading of screenshots, window titles, prompts, application lists, or local presets.
- Treat screenshots and OCR output as sensitive user data. Persist only what the documented storage flow requires.
- Process suspension is opt-in and single-player only. Never offer it for kernel-anti-cheat games.
- A suspended game must always be resumed on popup close, application exit, signals, errors, and watchdog detection of a disappeared popup or application.

## Validation

For documentation changes:

- Run `make docs`.
- Check that local Markdown links resolve.
- Check contiguous ADR numbering, filename/title agreement, and exactly one index entry per ADR.
- Check for stale references after renaming or removing files.

For implementation changes:

- Run `make build`, `make test`, and `make lint`.
- Exercise the relevant end-to-end behavior, not just imports or compilation.
- Cover coordinate conversions, response parsing, configuration inheritance, deduplication, and process-resume safety with tests when those areas are implemented.
