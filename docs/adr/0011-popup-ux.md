# ADR-0011: Popup interaction and state model

- Status: Accepted
- Date: 2026-11-25

## Context

Lookup is a brief interaction layered over another application. The popup must provide translation and backlog actions without stealing focus or leaving the user uncertain about progress. The word and its visual subject may also be in different parts of the screen, so automatic word cropping is not always sufficient.

## Decision

The popup:

- appears near the cursor and does not steal focus;
- closes with Esc, ✕, or the same hotkey again;
- uses the state sequence `loading → translated → saved / already-saved / error`;
- auto-hides errors after approximately 2.5 seconds;
- provides “＋ Add to backlog,” “remember this window,” and ✕ actions;
- provides “Select card image” when the configured `imageCropMode` is not `off`;
- shows the word → lemma · part of speech, translation, note, and source line;
- shows “✓ In backlog” immediately when the lemma is already saved.

Image behavior depends on `imageCropMode`:

- `word`: “＋ Add to backlog” immediately uses the automatic crop around the word. “Select card image” remains available as a manual override.
- `region`: “＋ Add to backlog” opens the region selector before saving an image. Confirming the selection completes the save; “Save without image” bypasses it. “Select card image” can reopen the selector to adjust the region.
- `off`: the popup saves without an image and does not show the image-selection action.

The region-selection overlay uses the multi-display frame set captured for the current lookup. The user drags a rectangle around the visual subject within the originating display's frame. If `imageAspectRatio` is set, the drag is constrained to that ratio; `null` allows a free-form rectangle.

Cancelling selection returns to the popup without discarding the translation or changing the selected word. A confirmed manual region takes precedence over the automatic word crop.

## Consequences

- OCR results can be displayed while translation is still in flight.
- Save and duplicate states are explicit.
- Repeated lookup of an existing lemma does not produce another backlog entry.
- The user can continue interacting with the source application without a focus change.
- The word and its visual subject can be in different parts of the screen without forcing an irrelevant card image.
- Manual image selection adds interaction only in `region` mode or when explicitly requested in `word` mode.
- Users can always save a text-only card, even when manual image selection is configured.
