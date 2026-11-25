# ADR-0010: LLM response contract and lenient parsing

- Status: Accepted
- Date: 2026-11-25

## Context

The core needs structured lemma, translation, part-of-speech, and note fields. Providers differ in structured-output support, and models can wrap JSON in Markdown fences or omit fields.

## Decision

Use this response contract:

```json
{
  "lemma": "dictionary form (infinitive / nominative singular / masculine)",
  "translation": "contextual translation, 1–3 words",
  "part_of_speech": "noun, masculine / verb / adjective …",
  "note": "word form in the text or a nuance; may be empty"
}
```

Use JSON schema or structured outputs where supported, but do not require them.

Make the parser lenient:

- extract `{...}` from responses, including responses wrapped in ```json fences;
- use defaults for missing fields;
- use the original word when `lemma` is empty.

## Consequences

- Providers with and without structured-output support share the same contract.
- Minor model formatting deviations do not make a lookup unusable.
- Missing data degrades to defaults rather than failing the entire response.
