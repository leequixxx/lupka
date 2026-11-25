# ADR-0014: Process pause and stop-frame mode

- Status: Accepted
- Date: 2026-11-25

## Context

Two game scenarios break the basic point-at-a-word flow:

1. Games without a proper pause can continue dialogue or cutscenes while the user reads a translation, forcing the user to race the game.
2. Games without a visible cursor, including subtitle-only sequences and console-style UI, provide no pointer for the normal word hit test.

Process suspension can solve the timing problem, but it has compatibility and safety risks.

## Decision

### Optional pause on lookup

Support a per-window `pauseOnLookup` flag:

```
hotkey → suspend the game process → popup → close popup (Esc / save) → resume the process
```

Platform mechanics:

- macOS: send `SIGSTOP`/`SIGCONT` to the game process and its children, **except `wineserver`** under CrossOver, because suspending it hangs the bottle’s IPC;
- Windows: use `NtSuspendProcess`/`NtResumeProcess`, equivalent to Suspend in Process Explorer;
- administrator/root permissions are not required for the user’s own processes.

This is scheduler-level suspension: threads stop at the current instruction, memory and handles remain intact, and execution resumes from the suspended state.

### Stop-frame capture for games without a cursor

Provide a second hotkey with this flow:

```
pause process → full-frame screenshot → full-frame OCR → dimmed overlay
→ target selection through lookupMode (point or region) → normal lookup popup → resume process
```

In `point` mode, the user clicks a word. In `region` mode, the user drags the OCR region and then clicks a word inside it. Reuse the point-in-box hit test from cursor-based lookup; only the point source changes. These are the full-frame game variants of the manual lookup modes defined in ADR-0004.

Full-frame OCR is slower (~0.5–1 s), but the game is suspended and the user is not racing changing content. Subtitles are a favorable OCR case because they typically use large, high-contrast text.

Stop-frame always suspends the process so the underlying scene cannot advance. `pauseOnLookup` remains optional for ordinary `hover`, `point`, and `region` lookups outside stop-frame capture. Stop-frame is unavailable for online games and kernel-anti-cheat titles: the second hotkey must not suspend those processes.

## Consequences

- Users can read translations without dialogue continuing in supported single-player games.
- Stop-frame enables lookup when no cursor is available.
- Process suspension is isolated behind an explicit per-window opt-in.
- Online games are unsupported because a suspended client disconnects on timeout; the UI must state this when enabling `pauseOnLookup` or stop-frame.
- Do not offer `pauseOnLookup` or stop-frame for games with kernel anti-cheat (EAC/BattlEye/Vanguard), because externally stopping threads may be interpreted as interference.
- Not all engines resume perfectly; audio glitches and internal timer jumps are possible, so the feature is tested per game.
- Pause logic lives in the platform shells; the core only receives lookup started/ended events.

Enforce this safety invariant: a game must never remain suspended. Resume when the popup closes, when the app exits, in signal handlers, and through a watchdog that resumes the process if the popup or app disappears.

## Alternatives considered

- **In-game pause APIs or simulated Esc/P keypresses** — games rarely expose pause APIs, and key simulation fails in the dialogue and cutscenes where pause is needed most.
- **Region-drag selection as the universal no-cursor default** — adds a drag before every lookup; offer it as a per-window `region` mode instead of imposing it everywhere.
