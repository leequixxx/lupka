# ADR-0015: Federated preset registry

- Status: Accepted
- Date: 2026-11-25

## Context

Per-window presets contain valuable game-specific knowledge: matchers, prompt suffixes, and sink routing. Users need a way to discover and share presets without a central backend, silent collection of local configuration, or a single maintainer becoming a bottleneck. Custom and language-specific communities also need control over their own preset sources.

## Decision

### Registry as a git repository

A registry is a git repository containing JSON preset files and a manifest mapping each game to a file, version, and hash. No special hosting is required.

The app subscribes to a list of registries: the official `lupka-io/presets` plus arbitrary custom registries configured by URL and priority. Updates use git/raw fetch with ETag caching.

- Store one preset per game per repository, keyed by a canonical ID such as a Steam app ID. Keep platform-specific `appId` and `processName` values inside the preset’s matchers rather than treating a macOS bundle ID as a universal game ID.
- Accept contributions through pull requests with CI validation: JSON schema, regex syntax, duplicate IDs, and rejection of URLs, keys, commands, or machine-specific `executablePath` fields in shared preset data.
- Show parallel versions when a game exists in multiple registries, including source and verification labels. The user chooses the source and can switch it.

### Configuration inheritance

Extend the configuration chain to:

```
default → profile → registry preset → local patch → window
```

A local patch stores only field deltas, so registry updates do not overwrite local changes.

### Publishing and trust

Export preset JSON for manual contribution through a pull request.

Presets are pure data, not executable code. The client validates the schema when a registry is added and displays an explicit trust prompt for unofficial sources. Maintainers can mark verified presets, and users can report broken presets as issues. When a running app has a known ID, the app can offer to install an available preset.

## Consequences

- Sharing is strictly opt-in. The app does not silently upload window titles, prompts, application lists, or local presets.
- Registry updates preserve local patches.
- Community presets remain openly available and can be hosted by independent communities.
- CI validation reduces maintainer review work, while federation prevents the official registry from becoming the only contribution path.
- Git hosting and ETag caching avoid operating a dedicated registry backend.

## Alternatives considered

- **Silent cloud collection** — incompatible with explicit consent and user trust.
- **Central server-side registry with a custom backend** — adds operational cost and a trust burden that git repositories avoid.
- **Single official registry only** — makes the maintainer a bottleneck and excludes niche or language-specific communities.
