# ADR-0006: Window identification through a matcher cascade

- Status: Accepted
- Date: 2026-11-25

## Context

Prompts, lookup behavior, and storage destinations can depend on the source application or window. A single identifier is insufficient: browsers host many sources, Wine/CrossOver applications expose different process and application identities, and Windows does not have a universal equivalent of the macOS bundle ID.

## Decision

### Platform-neutral window facts

Each shell passes a flat `WindowFacts` record to the core:

| Field | Meaning |
|---|---|
| `appId?` | macOS bundle ID or Windows AppUserModelID (AUMID), when available |
| `processName` | Platform process name, such as `witcher3`, `witcher3.exe`, or `wine64` |
| `executablePath?` | Native executable path for cases that need additional disambiguation |
| `windowTitle?` | Current window title when available |

A Windows AUMID is optional: packaged applications commonly have one, while ordinary unpackaged executables may not. Missing `appId` is a normal case and must not prevent process or title matching.

The shells collect these facts through platform APIs:

- **macOS:** use `NSWorkspace.frontmostApplication` for bundle ID and process information without additional permissions. Read window titles through the Accessibility API only when optional permission is granted.
- **Windows:** use `GetForegroundWindow` and `GetWindowThreadProcessId` to identify the process, query its executable name/path, and obtain the AUMID when available. Read the native window title from the foreground window.

The core owns matching and platform-appropriate normalization. In particular, Windows `processName` matching is case-insensitive.

### Matcher cascade

Use a matcher cascade rather than a single key:

```
appId → processName (+ optional executablePath) → windowTitle regex → no match
                                                                      ↓
                                                          manual pin from the menu bar
```

- `appId` is the strongest portable application-level matcher when present, but its value and availability remain platform-specific.
- `processName` covers applications without an app ID. An optional `executablePath` can disambiguate identically named processes but must not be required for a portable preset.
- Window titles distinguish sources inside the same process, such as a YouTube video in a browser or a game under Wine.
- For CrossOver/Wine on macOS, expect the bundle ID to belong to CrossOver and the process to be `wine64`; rely on the window title because Wine proxies it to the Cocoa window.
- Provide manual pinning as the final reliability mechanism. A pinned context remains active until cleared.
- Let the popup’s “remember this window” button add matchers to the config automatically; the user only edits the description.

## Consequences

- Matching behavior is shared by the core, while platform APIs remain inside the shells.
- Automatic matching handles applications with or without a platform app ID.
- Process matching works for unpackaged Windows applications, and title matching handles browsers and Wine.
- `executablePath` is machine-specific and should remain in local overrides rather than shared registry presets.
- Manual pinning provides deterministic behavior when automatic matching fails and can be more convenient for gaming sessions.
- Window-title matching on macOS is unavailable without the optional Accessibility permission.
