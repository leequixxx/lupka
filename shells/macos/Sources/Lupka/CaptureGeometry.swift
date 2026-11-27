import AppKit
import CoreGraphics

struct CaptureConfiguration: Equatable, Sendable {
    static let `default` = CaptureConfiguration()

    let excludedDisplayIDs: Set<CGDirectDisplayID>

    init(excludedDisplayIDs: Set<CGDirectDisplayID> = []) {
        self.excludedDisplayIDs = excludedDisplayIDs
    }
}

struct DisplayGeometry: Equatable {
    let displayID: CGDirectDisplayID
    let displayFrame: CGRect
}

struct CapturedDisplayFrame {
    let image: CGImage
    let displayID: CGDirectDisplayID
    let displayFrame: CGRect
}

struct CapturedFrame {
    let displays: [CapturedDisplayFrame]
    let pointer: CGPoint
    let pointerDisplayID: CGDirectDisplayID

    var desktopFrame: CGRect {
        displays.reduce(CGRect.null) { desktopFrame, display in
            desktopFrame.union(display.displayFrame)
        }
    }

    var pointerInImage: CGPoint? {
        imagePoint(forDesktopPoint: pointer, displayID: pointerDisplayID)
    }

    func imagePoint(forDesktopPoint point: CGPoint, displayID: CGDirectDisplayID) -> CGPoint? {
        guard let display = displays.first(where: { $0.displayID == displayID }),
            display.displayFrame.contains(point)
        else {
            return nil
        }

        // Global CG points are converted to this display's local image pixels, both from the top left.
        let pointInDisplay = CGPoint(
            x: point.x - display.displayFrame.minX,
            y: point.y - display.displayFrame.minY
        )
        return CGPoint(
            x: pointInDisplay.x * CGFloat(display.image.width) / display.displayFrame.width,
            y: pointInDisplay.y * CGFloat(display.image.height) / display.displayFrame.height
        )
    }

    func desktopPoint(forImagePoint point: CGPoint, displayID: CGDirectDisplayID) -> CGPoint? {
        guard let display = displays.first(where: { $0.displayID == displayID }) else {
            return nil
        }

        // Image pixels are converted back to global CG points using the captured display frame.
        return CGPoint(
            x: display.displayFrame.minX
                + point.x * display.displayFrame.width / CGFloat(display.image.width),
            y: display.displayFrame.minY
                + point.y * display.displayFrame.height / CGFloat(display.image.height)
        )
    }
}

enum CaptureGeometry {
    static func coreGraphicsPoint(
        fromAppKitPoint point: NSPoint,
        primaryScreenHeight: CGFloat
    ) -> CGPoint {
        // AppKit measures Y upward from the primary display; CG and ScreenCaptureKit measure it downward.
        CGPoint(x: point.x, y: primaryScreenHeight - point.y)
    }

    static func includedDisplays(
        _ displays: [DisplayGeometry],
        configuration: CaptureConfiguration
    ) -> [DisplayGeometry] {
        displays
            .filter { !configuration.excludedDisplayIDs.contains($0.displayID) }
            .sorted { first, second in
                if first.displayFrame.minY != second.displayFrame.minY {
                    return first.displayFrame.minY < second.displayFrame.minY
                }
                if first.displayFrame.minX != second.displayFrame.minX {
                    return first.displayFrame.minX < second.displayFrame.minX
                }
                return first.displayID < second.displayID
            }
    }
}
