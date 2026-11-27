import CoreGraphics
import Testing

@testable import Lupka

@Test
func pointerInImageUsesPixelScale() throws {
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 2_880, height: 1_800),
                displayID: 1,
                displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
            )
        ],
        pointer: CGPoint(x: 720, y: 450),
        pointerDisplayID: 1
    )

    #expect(capture.pointerInImage == CGPoint(x: 1_440, y: 900))
}

@Test
func pointerInImageUsesSecondaryDisplayOrigin() throws {
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 1_280, height: 1_024),
                displayID: 2,
                displayFrame: CGRect(x: -1_280, y: 0, width: 1_280, height: 1_024)
            )
        ],
        pointer: CGPoint(x: -640, y: 512),
        pointerDisplayID: 2
    )

    #expect(capture.pointerInImage == CGPoint(x: 640, y: 512))
}

@Test
func pointerInImageUsesDisplayAboveOrigin() throws {
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 1_440, height: 900),
                displayID: 3,
                displayFrame: CGRect(x: 0, y: -900, width: 1_440, height: 900)
            )
        ],
        pointer: CGPoint(x: 720, y: -450),
        pointerDisplayID: 3
    )

    #expect(capture.pointerInImage == CGPoint(x: 720, y: 450))
}

@Test
func desktopFrameUnionsAllCapturedDisplays() throws {
    let image = try makeImage(width: 1, height: 1)
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: image,
                displayID: 1,
                displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
            ),
            CapturedDisplayFrame(
                image: image,
                displayID: 2,
                displayFrame: CGRect(x: -1_440, y: 0, width: 1_440, height: 900)
            ),
            CapturedDisplayFrame(
                image: image,
                displayID: 3,
                displayFrame: CGRect(x: 0, y: -900, width: 1_440, height: 900)
            ),
        ],
        pointer: .zero,
        pointerDisplayID: 1
    )

    #expect(capture.desktopFrame == CGRect(x: -1_440, y: -900, width: 2_880, height: 1_800))
}

@Test
func imageAndDesktopCoordinatesRoundTripAcrossDisplayOrigin() throws {
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 2_560, height: 1_440),
                displayID: 2,
                displayFrame: CGRect(x: -1_280, y: 0, width: 1_280, height: 720)
            )
        ],
        pointer: CGPoint(x: -1_230, y: 100),
        pointerDisplayID: 2
    )
    let imagePoint = CGPoint(x: 100, y: 200)

    let desktopPoint = try #require(
        capture.desktopPoint(forImagePoint: imagePoint, displayID: 2)
    )

    #expect(desktopPoint == CGPoint(x: -1_230, y: 100))
    #expect(capture.imagePoint(forDesktopPoint: desktopPoint, displayID: 2) == imagePoint)
}

@Test
func imagePointRejectsPointOutsideSelectedDisplay() throws {
    let capture = LookupCapture(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 1_440, height: 900),
                displayID: 1,
                displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
            )
        ],
        pointer: CGPoint(x: -100, y: 100),
        pointerDisplayID: 2
    )

    #expect(capture.imagePoint(forDesktopPoint: capture.pointer, displayID: 1) == nil)
    #expect(capture.pointerInImage == nil)
}
