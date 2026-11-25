# ADR-0012: Backlog storage through sink providers

- Status: Accepted
- Date: 2026-11-25

## Context

Lookup results need deduplication and export without coupling the core to a particular storage format. A profile or window may require multiple independent destinations, and the backlog must remain open text. Card images also need a manual override because the word and the object or scene it describes may appear in different parts of the screen.

## Decision

Write results through a sink abstraction, analogous to LLM providers. The core knows only the interface:

```rust
trait Sink {
    fn contains(&self, lemma: &str) -> bool;   // deduplication for the popup (ADR-0011)
    fn add(&self, entry: &LookupEntry) -> Result<AddOutcome>; // Added | Duplicate
}
```

`LookupEntry` is the canonical core record:

```
lemma, translation, partOfSpeech, note, context (source line),
sourceApp, imagePath?, timestamp
```

All sinks consume this record.

Bundle these sinks:

| Sink | Status | Format |
|---|---|---|
| `markdown` | v1 | `lemma :: translation 📷` line in a Markdown file |
| `csv` | v1 | `lemma,translation,pos,note,context,source,date,image` — universal import into anything |

Bind sinks to a language profile and allow window overrides using the inheritance rules in ADR-0007 and ADR-0008. A profile can have multiple sinks (fan-out), such as `markdown` as a readable backlog and `csv` as a raw archive. Deduplication and writes happen independently for each sink.

```json
"sinks": {
  "markdown": { "type": "markdown", "file": "Backlog/Games.md" },
  "archive":  { "type": "csv", "file": "Backlog/archive.csv" }
}
```

A window override references a sink by name (`"sink": "archive"`) or a group; an empty field is inherited.

Use this Markdown line format:

```
lemma :: translation 📷
```

`📷` means an image is available. Deduplicate by lemma using a case-insensitive line-prefix comparison.

Configure image capture per window through `imageCropMode`:

- `word` (default): use a square around the word box, with side = max(4× word width, 10× height, 260 px), constrained to the captured frame. The user can override it with a manual selection.
- `region`: the user selects the image rectangle before saving with an image. Saving without an image remains available.
- `off`: do not create an image and leave `imagePath` empty.

`imageAspectRatio` constrains manual selection: `null` means free-form, while values such as `"1:1"`, `"4:3"`, or `"16:9"` enforce the corresponding ratio. The setting has no effect in `off` mode.

Save images before invoking sinks:

- treat a confirmed manual selection as authoritative for the current lookup, even when it does not contain the word;
- pass the selected rectangle from the platform shell to the core, and crop the original captured frame rather than taking a new screenshot after the source application has changed;
- write the resulting image to `<imagesDir>/<lemma>.png`, using a sanitized lemma as the filename;
- pass the resulting `imagePath` to every sink.

## Consequences

- Storage formats are independent of core business logic, and adding an exporter is a core-only change across platforms.
- Multiple destinations can receive the same entry without sharing deduplication state.
- `contains()` must be cheap because it powers in-popup deduplication; Markdown and CSV sinks index case-insensitive lemma prefixes.
- Markdown and CSV remain open text with no dependency on a specific notes app or synchronization service.
- A card can show the relevant object or scene rather than being limited to the word’s bounding box.
- Manual selection does not trigger a second capture, so the card image remains synchronized with the lookup context.
- Sinks receive ready-made image paths and do not perform image processing.

## Alternatives considered

- **Single hardcoded Markdown writer** — locks users into one storage workflow.
- **SQLite as the only storage** — violates the open-text backlog principle. It must not be the source of truth.
