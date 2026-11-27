import AppKit
import LupkaCore

let info = coreInfo()
writeToConsole("\(info.name) \(info.version)")

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
let coordinator = LookupCoordinator(
    capturer: ScreenCaptureService(),
    pointerLocator: PointerLocator(),
    lookupFlow: BootstrapLookupFlow(),
    onError: presentError
)
let delegate = AppDelegate(coordinator: coordinator, onError: presentError)
application.delegate = delegate
application.run()
