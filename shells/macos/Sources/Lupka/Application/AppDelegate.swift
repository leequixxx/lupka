import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let coordinator: LookupCoordinator
    private let hotKey: CarbonHotKey
    private let onError: (Error) -> Void

    init(coordinator: LookupCoordinator, onError: @escaping (Error) -> Void) {
        self.coordinator = coordinator
        self.onError = onError
        hotKey = CarbonHotKey {
            Task {
                await coordinator.handleHotKey()
            }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            try hotKey.start()
            writeToConsole("Lupka is running. Press \(HotKeyDefinition.default.displayName) to capture.")
        } catch {
            onError(error)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKey.stop()
    }
}

@MainActor
func presentError(_ error: Error) {
    let message = error.localizedDescription
    writeToConsole("Error: \(message)", to: FileHandle.standardError)

    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Lupka"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    alert.runModal()
}

func writeToConsole(_ message: String, to handle: FileHandle = .standardOutput) {
    handle.write(Data("\(message)\n".utf8))
}
