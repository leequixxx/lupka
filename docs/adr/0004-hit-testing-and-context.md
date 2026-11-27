# ADR-0004: Word hit testing and context extraction

- Status: Accepted
- Date: 2026-11-25

## Context

OCR produces words and bounding boxes, but lookup needs a specific target word and enough surrounding text for a contextual translation. The normal pointer is not always available in games, and automatic capture can include unrelated UI or multiple text columns. Coordinate conversion between platform APIs is particularly error-prone.

## Decision

### Lookup modes

Configure target and context selection per window through `lookupMode`:

| Mode | Target word | OCR context |
|---|---|---|
| `hover` | Current pointer position when the hotkey is pressed | Automatic capture around the pointer |
| `point` | A word clicked on a dimmed captured frame | Automatic extraction around the clicked word |
| `region` | A word clicked inside a user-selected region | Restricted to the selected region |

`hover` is the default and preserves the fastest flow.

`point` captures and dims the current frame, then lets the user click a word. It is useful when the application has no visible system cursor or the pointer cannot remain over the word.

`region` adds a drag step before the click: the user selects the text area and then chooses the target word inside it. This excludes unrelated UI and other columns. The additional interaction is justified only for windows that need it.

Manual modes use the same captured frame throughout selection. `pauseOnLookup` remains an independent setting; stop-frame behavior for games is defined in ADR-0014.

### Hit testing and context

Use the same point-in-box hit test for every mode: select the bounding box containing the target point with a 3 px tolerance. On a miss, use the nearest box within approximately 14 px; otherwise, return “no word under the cursor.”

In `hover` and `point` modes, build the context from all words whose boxes intersect the target’s vertical band (±60% of its height), joined left to right. In `region` mode, apply the same rule only to words inside the selected region.

### Coordinate conversion

Treat coordinate conversion as a dedicated, tested boundary:

- AppKit: Y from the bottom, relative to the main display;
- CG/ScreenCaptureKit: Y from the top;
- Vision: normalized 0–1 coordinates, Y from the bottom;
- Captured display image: pixel coordinates, Y from the top; its `displayFrame` locates it in global CG coordinates.

The shell passes one full image per selected display plus each display's global frame. No synthetic stitched screenshot is required. OCR boxes remain in local image pixels for hit testing and cropping. To join context across adjacent displays, convert those boxes into shared global CG coordinates before line joining.

Each conversion must be explicit, commented, and covered by tests. Pointer, click, and drag coordinates must be converted into the corresponding display's image coordinates before hit testing or cropping. Cross-display context uses global CG coordinates rather than mixing local image origins or pixel scales.

## Consequences

- The default lookup remains a single hotkey, while manual selection is available where automatic targeting is unreliable.
- `point` adds one click and `region` adds a drag plus a click, so these modes are per-window choices rather than global defaults.
- Manual lookup and image selection do not require a second screenshot.
- Multiline context is not supported; dialogue rarely fits on one line.
- Languages without spaces (ja/zh/th) are not supported because a box is not necessarily a word and morphological segmentation is required.
- RTL languages such as Arabic and Hebrew require line joining order that is not currently handled.
