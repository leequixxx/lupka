import CoreGraphics
import Testing

@testable import Lupka

@Test
func appKitPointerConvertsToTopLeftCoordinates() {
    let primaryDisplayPoint = CaptureGeometry.coreGraphicsPoint(
        fromAppKitPoint: CGPoint(x: 100, y: 100),
        primaryScreenHeight: 1_080
    )
    let displayAbovePoint = CaptureGeometry.coreGraphicsPoint(
        fromAppKitPoint: CGPoint(x: 100, y: 1_200),
        primaryScreenHeight: 1_080
    )

    #expect(primaryDisplayPoint == CGPoint(x: 100, y: 980))
    #expect(displayAbovePoint == CGPoint(x: 100, y: -120))
}

@Test
func includedDisplaysAreOrderedAndHonorExclusions() {
    let main = DisplayGeometry(
        displayID: 1,
        displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
    )
    let left = DisplayGeometry(
        displayID: 2,
        displayFrame: CGRect(x: -1_440, y: 0, width: 1_440, height: 900)
    )
    let above = DisplayGeometry(
        displayID: 3,
        displayFrame: CGRect(x: 0, y: -900, width: 1_440, height: 900)
    )

    let all = CaptureGeometry.includedDisplays(
        [main, left, above],
        configuration: .default
    )
    let withoutLeft = CaptureGeometry.includedDisplays(
        [main, left, above],
        configuration: CaptureConfiguration(excludedDisplayIDs: [2])
    )

    #expect(all.map(\.displayID) == [3, 2, 1])
    #expect(withoutLeft.map(\.displayID) == [3, 1])
}

@Test
func pointerInImageUsesPixelScale() throws {
    let frame = CapturedFrame(
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

    #expect(frame.pointerInImage == CGPoint(x: 1_440, y: 900))
}

@Test
func pointerInImageUsesSecondaryDisplayOrigin() throws {
    let frame = CapturedFrame(
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

    #expect(frame.pointerInImage == CGPoint(x: 640, y: 512))
}

@Test
func pointerInImageUsesDisplayAboveOrigin() throws {
    let frame = CapturedFrame(
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

    #expect(frame.pointerInImage == CGPoint(x: 720, y: 450))
}

@Test
func desktopFrameUnionsAllCapturedDisplays() throws {
    let image = try makeImage(width: 1, height: 1)
    let frame = CapturedFrame(
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

    #expect(frame.desktopFrame == CGRect(x: -1_440, y: -900, width: 2_880, height: 1_800))
}

@Test
func imageAndDesktopCoordinatesRoundTripAcrossDisplayOrigin() throws {
    let frame = CapturedFrame(
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
        frame.desktopPoint(forImagePoint: imagePoint, displayID: 2)
    )

    #expect(desktopPoint == CGPoint(x: -1_230, y: 100))
    #expect(frame.imagePoint(forDesktopPoint: desktopPoint, displayID: 2) == imagePoint)
}

@Test
func imagePointRejectsPointOutsideSelectedDisplay() throws {
    let frame = CapturedFrame(
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

    #expect(frame.imagePoint(forDesktopPoint: frame.pointer, displayID: 1) == nil)
    #expect(frame.pointerInImage == nil)
}

func makeImage(width: Int, height: Int) throws -> CGImage {
    let context = try #require(
        CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    )
    return try #require(context.makeImage())
}
