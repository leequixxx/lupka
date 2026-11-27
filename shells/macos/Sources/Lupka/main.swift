import AppKit
import LupkaCore

@MainActor
final class BootstrapLookupFlow: LookupFlow {
    func lookup(_ frame: CapturedFrame) async {
        let captures = frame.displays.map {
            "\($0.displayID): \($0.image.width)×\($0.image.height) px"
        }.joined(separator: ", ")
        writeToConsole(
            "Captured \(frame.displays.count) display(s) [\(captures)]; pointer on display \(frame.pointerDisplayID), in image: \(String(describing: frame.pointerInImage))."
        )
    }
}

let info = coreInfo()
writeToConsole("\(info.name) \(info.version)")

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
let coordinator = LookupCoordinator(
    capturer: ScreenCaptureService(),
    lookupFlow: BootstrapLookupFlow(),
    onError: presentError
)
let delegate = AppDelegate(coordinator: coordinator, onError: presentError)
application.delegate = delegate
application.run()
