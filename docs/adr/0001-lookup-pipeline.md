# ADR-0001: Lookup pipeline and latency budget

- Status: Accepted
- Date: 2026-11-25

## Context

Lupka provides contextual translation for words on screen without interrupting the user’s current activity. The popup must feel immediate even though OCR and LLM translation have different latency profiles. Some windows also require manual target, context, or card-image selection.

## Decision

Use the following pipeline:

```
hotkey → screenshot according to lookupMode → OCR → target word (hover / point / region)
→ context line → LLM (lemma + translation + part of speech + note)
→ popup → image crop (word / region / off) → [add to backlog]
→ write through a sink (ADR-0012) + optional imagePath
```

`lookupMode` controls target and context selection before OCR (ADR-0004). `imageCropMode` controls automatic, manual, or disabled image creation during the save flow (ADR-0011 and ADR-0012). Manual interactions reuse the original captured frame.

The latency budget for the default `hover` mode is:

- popup with OCR results: ≤ 300 ms;
- translation loaded afterward: ≤ 1.5 s.

Show the word and source line first, then replace “Translating…” with the translation. The user must never wait on an empty popup.

## Consequences

- OCR and translation have separate UI states and can complete independently.
- The translation path is asynchronous and does not block display of the OCR result.
- Latency takes priority over model intelligence throughout the lookup design.
- Manual `point` and `region` interactions add user-controlled time and are not part of the automatic latency budget.
- The default `hover + word` flow remains the fastest path; more deliberate modes are selected per window.
