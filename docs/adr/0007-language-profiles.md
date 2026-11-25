# ADR-0007: Language profiles

- Status: Accepted
- Date: 2026-11-25

## Context

OCR languages, prompt language names, prompt additions, and storage destinations all depend on the active language pair. These settings should switch together rather than being configured independently.

## Decision

Represent each language pair as a profile switchable from the menu bar. A profile contains all language-dependent settings:

```json
{
  "profiles": {
    "pl→ru": {
      "ocrLanguages": ["pl-PL"],
      "source": "Polish",
      "target": "Russian",
      "sinks": ["markdown"],
      "systemSuffix": ""
    },
    "de→ru": {
      "ocrLanguages": ["de-DE"],
      "source": "German",
      "target": "Russian",
      "sinks": ["markdown-de"],
      "systemSuffix": "For nouns, always include the article der/die/das in note."
    }
  },
  "activeProfile": "pl→ru"
}
```

Bind sinks to the profile so that each language can use its own storage or folder.

## Consequences

- Switching a profile changes the complete language-dependent configuration.
- Words from different languages do not need to share storage.
- Window overrides can refine profile settings through the inheritance rules in ADR-0008.
