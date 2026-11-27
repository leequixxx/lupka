import AppKit

struct PointerSnapshot {
    let position: CGPoint
    let displayID: CGDirectDisplayID
}

enum PointerLocationError: LocalizedError {
    case displayNotFound

    var errorDescription: String? {
        "Lupka could not match the pointer to a display."
    }
}

@MainActor
protocol PointerLocating {
    func pointer() throws -> PointerSnapshot
}

@MainActor
final class PointerLocator: PointerLocating {
    func pointer() throws -> PointerSnapshot {
        let appKitPointer = NSEvent.mouseLocation
        let screens = NSScreen.screens
        guard let primaryScreen = screens.first,
            let pointerScreen = screens.first(where: { $0.frame.contains(appKitPointer) }),
            let displayID = pointerScreen.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")
            ] as? CGDirectDisplayID
        else {
            throw PointerLocationError.displayNotFound
        }

        return PointerSnapshot(
            position: Self.coreGraphicsPoint(
                fromAppKitPoint: appKitPointer,
                primaryScreenHeight: primaryScreen.frame.height
            ),
            displayID: displayID
        )
    }

    static func coreGraphicsPoint(
        fromAppKitPoint point: NSPoint,
        primaryScreenHeight: CGFloat
    ) -> CGPoint {
        // AppKit measures Y upward from the primary display; CG and ScreenCaptureKit measure it downward.
        CGPoint(x: point.x, y: primaryScreenHeight - point.y)
    }
}
