import AppKit
import CoreGraphics
import ScreenCaptureKit

enum ScreenCaptureError: LocalizedError {
    case permissionDenied
    case unsupportedOperatingSystem
    case displayNotFound
    case pointerDisplayExcluded

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Lupka needs Screen Recording permission to capture the screen. Enable it in System Settings → Privacy & Security → Screen Recording. If you launched Lupka from a terminal, grant permission to that terminal application, then restart Lupka."
        case .unsupportedOperatingSystem:
            "Screen capture requires macOS 14 or later because Lupka uses SCScreenshotManager."
        case .displayNotFound:
            "Lupka could not match the pointer to a capturable display."
        case .pointerDisplayExcluded:
            "The display under the pointer is excluded from capture. Enable that display or move the pointer to an included display."
        }
    }
}

struct ScreenCapturePermission {
    var preflight: () -> Bool = { CGPreflightScreenCaptureAccess() }
    var request: () -> Bool = { CGRequestScreenCaptureAccess() }
}

@MainActor
protocol ScreenCapturing {
    func capture() async throws -> CapturedFrame
}

@MainActor
final class ScreenCaptureService: ScreenCapturing {
    private let configuration: CaptureConfiguration
    private let permission: ScreenCapturePermission

    init(
        configuration: CaptureConfiguration = .default,
        permission: ScreenCapturePermission = ScreenCapturePermission()
    ) {
        self.configuration = configuration
        self.permission = permission
    }

    func capture() async throws -> CapturedFrame {
        guard #available(macOS 14.0, *) else {
            throw ScreenCaptureError.unsupportedOperatingSystem
        }

        let appKitPointer = NSEvent.mouseLocation
        let screens = NSScreen.screens
        guard let primaryScreen = screens.first,
            let pointerScreen = screens.first(where: { $0.frame.contains(appKitPointer) }),
            let displayID = pointerScreen.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")
            ] as? CGDirectDisplayID
        else {
            throw ScreenCaptureError.displayNotFound
        }

        // Preserve the hotkey-time pointer before permission prompts or asynchronous capture can change it.
        let pointer = CaptureGeometry.coreGraphicsPoint(
            fromAppKitPoint: appKitPointer,
            primaryScreenHeight: primaryScreen.frame.height
        )
        guard permission.preflight() || permission.request() else {
            throw ScreenCaptureError.permissionDenied
        }

        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )
        guard content.displays.contains(where: { $0.displayID == displayID }) else {
            throw ScreenCaptureError.displayNotFound
        }
        guard !configuration.excludedDisplayIDs.contains(displayID) else {
            throw ScreenCaptureError.pointerDisplayExcluded
        }

        let geometry = content.displays.map {
            DisplayGeometry(displayID: $0.displayID, displayFrame: $0.frame)
        }
        let includedGeometry = CaptureGeometry.includedDisplays(
            geometry,
            configuration: configuration
        )
        let displaysByID = Dictionary(
            uniqueKeysWithValues: content.displays.map { ($0.displayID, $0) }
        )
        var capturedDisplays: [CapturedDisplayFrame] = []
        capturedDisplays.reserveCapacity(includedGeometry.count)

        for displayGeometry in includedGeometry {
            guard let display = displaysByID[displayGeometry.displayID] else {
                throw ScreenCaptureError.displayNotFound
            }
            let image = try await captureImage(
                display: display,
                sourceRect: CGRect(origin: .zero, size: display.frame.size)
            )
            capturedDisplays.append(
                CapturedDisplayFrame(
                    image: image,
                    displayID: displayGeometry.displayID,
                    displayFrame: displayGeometry.displayFrame
                )
            )
        }

        return CapturedFrame(
            displays: capturedDisplays,
            pointer: pointer,
            pointerDisplayID: displayID
        )
    }

    @available(macOS 14.0, *)
    private func captureImage(display: SCDisplay, sourceRect: CGRect) async throws -> CGImage {
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let scale = CGFloat(filter.pointPixelScale)
        let configuration = SCStreamConfiguration()
        configuration.sourceRect = sourceRect
        configuration.width = max(1, Int((sourceRect.width * scale).rounded()))
        configuration.height = max(1, Int((sourceRect.height * scale).rounded()))
        configuration.showsCursor = false
        configuration.captureResolution = .best

        return try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: configuration
        )
    }
}
