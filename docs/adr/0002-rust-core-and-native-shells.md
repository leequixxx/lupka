# ADR-0002: Rust core and native shells

- Status: Accepted
- Date: 2026-11-25

## Context

Lupka targets macOS and Windows, requires native popup behavior and platform APIs, and shares substantial business logic across platforms. Duplicating that logic would increase maintenance and behavioral drift, while a web UI would not meet the native UI requirement.

## Decision

Use a shared Rust core containing all business logic, with a native shell on each platform:

- macOS: Swift + SwiftUI, with AppKit for the popup;
- Windows: C# + WinUI 3.

Generate core ↔ shell bindings with **uniffi**. Swift has official support; C# uses `uniffi-bindgen-cs` (Nord Security, .NET 8+). Pin generator versions because the C# generator is still young. Do not add a Qt shell: a second toolkit would double platform code for cosmetic gains.

```
┌──────────────────┐   ┌──────────────────┐
│ macOS shell      │   │ Windows shell    │
│ Swift + SwiftUI  │   │ C# + WinUI 3     │
│ hotkey, capture, │   │ hotkey, capture, │
│ Vision OCR, popup│   │ WinRT OCR, popup │
└────────┬─────────┘   └────────┬─────────┘
         │   uniffi bindings    │
         └──────────┬───────────┘
             ┌──────▼──────┐
             │  Rust core  │
             └─────────────┘
```

The core owns:

- configuration and inheritance, including registry presets and local patches (ADR-0007, ADR-0008, and ADR-0015);
- LLM providers, adapters, and presets (ADR-0009);
- prompt templates and response parsing (ADR-0010);
- sink providers (ADR-0012);
- the window matcher cascade (ADR-0006);
- `WindowFacts`, `LookupEntry`, profiles, overrides, and other shared data models.

The shells own platform-specific functionality:

| Component | macOS | Windows |
|---|---|---|
| UI | SwiftUI (+ AppKit for the popup) | WinUI 3 |
| Hotkey | Carbon `RegisterEventHotKey` (no Accessibility permissions) | Win32 `RegisterHotKey` |
| Window facts | `NSWorkspace`, optional Accessibility | `GetForegroundWindow`, process and AUMID APIs |
| Screenshot | ScreenCaptureKit (`SCScreenshotManager`) | Graphics Capture API |
| OCR | Apple Vision | Windows.Media.Ocr (WinRT) |
| Popup | `NSPanel` `.nonactivatingPanel`, floating | Topmost window + `WS_EX_NOACTIVATE` |
| Keys | Keychain | Credential Manager |
| TTS | AVSpeechSynthesizer | SpeechSynthesis |

Keep the FFI boundary simple: flat data structures and strings, with no callbacks or shared ownership.

## Consequences

- The macOS shell targets macOS 13 or newer. Platform features with higher OS requirements remain optional and availability-checked.
- Business logic has one implementation across platforms.
- UI and system integration remain native.
- The simple FFI boundary reduces exposure to uniffi and borrow checker footguns.
- macOS requires Screen Recording permission, granted to the launching process. Accessibility permission is optional and only needed for window titles.
- Windows requires no screen capture permission.

## Alternatives considered

- **Electron** — globalShortcut, desktopCapturer, and overlay windows are well understood, but the UI is non-native, a roughly 200 MB runtime is excessive for a menu bar utility, and OCR would still require native helpers.
- **Tauri** — provides the desired Rust core, but its webview UI fails the native UI requirement.
- **Duplicating business logic in Swift and C#** — doubles maintenance and risks behavioral drift.
- **Flutter / Qt** — custom rendering produces a non-native appearance.
- **Accessibility API instead of OCR** — does not work in games or browser video; pixel-based OCR is universal.
