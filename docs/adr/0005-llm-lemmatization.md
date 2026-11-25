# ADR-0005: LLM-based lemmatization

- Status: Accepted
- Date: 2026-11-25

## Context

A learning backlog should store dictionary forms rather than inflected surface forms. Traditional dictionary tools require curated language-specific databases and deconjugation rules.

## Decision

Ask the LLM to return the dictionary form as part of the translation response:

- `mieczem → miecz`;
- `poszedłem → pójść`.

Do not ship dictionary files or maintain a dictionary database in the app.

## Consequences

- Any language and inflection supported by the selected LLM can be lemmatized without a language-specific database.
- Lemma quality depends on the model and prompt rather than curated local data.
- The app remains independent of dictionary file formats and distribution.

## Alternatives considered

- **Curated dictionary and deconjugation databases** — require separate data and maintenance for every language, as used by tools such as Lookupper and meikipop.
