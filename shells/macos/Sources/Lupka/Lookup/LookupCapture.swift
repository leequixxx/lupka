import CoreGraphics
import Foundation

struct LookupCapture {
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

enum LookupCaptureError: LocalizedError {
    case pointerDisplayNotCaptured

    var errorDescription: String? {
        "The display under the pointer is not enabled for capture. Enable that display or move the pointer to an enabled display."
    }
}
