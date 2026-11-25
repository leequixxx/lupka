# ADR-0008: Window overrides and semi-strict prompts

- Status: Accepted
- Date: 2026-11-25

## Context

Different windows can require different prompt context, lookup behavior, image cropping, process pause, and storage destinations, but duplicating complete profiles for every application would make configuration difficult to maintain. Custom prompts must also preserve the response contract expected by the parser.

## Decision

Use inheritance rather than isolated configurations:

```
default → language profile → registry preset → local patch → window override
```

Registry presets and delta-only local patches follow ADR-0015. Each level can override `lookupMode`, `imageCropMode`, `imageAspectRatio`, `pauseOnLookup`, `systemSuffix`, `sinks`, and, when necessary, the entire `userTemplate`. An empty field means inherited. `imageAspectRatio: null` explicitly selects free-form manual cropping.

```json
"apps": [
  {
    "name": "The Witcher 3",
    "match": {
      "appId": ["com.cdprojektred.witcher3"],
      "processName": ["witcher3", "witcher3.exe"],
      "windowTitle": ".*Witcher.*"
    },
    "systemSuffix": "The source is a fantasy RPG. Keep proper names in the original language and mark them in note.",
    "sinks": ["markdown-witcher"],
    "lookupMode": "region",
    "imageCropMode": "region",
    "imageAspectRatio": "16:9",
    "pauseOnLookup": true
  }
]
```

Use a semi-strict template with these variables:

- `{{word}}`
- `{{context}}`
- `{{app}}`
- `{{windowTitle}}`
- `{{source}}`
- `{{target}}`

The user’s `userTemplate` contains only the task description. The app appends the JSON schema block itself and does not expose it to user customization.

Well-known names need no additional description: the app name alone is often enough for the LLM. Overrides are for non-obvious context.

## Consequences

- Shared defaults remain concise while individual windows can specialize behavior.
- Lookup, image crop, aspect ratio, and process pause use the same inheritance model as prompts and sinks.
- Empty fields have consistent inheritance semantics.
- Users can customize prompts without accidentally breaking the parser’s response contract.
