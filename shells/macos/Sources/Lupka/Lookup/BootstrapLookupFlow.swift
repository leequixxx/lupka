@MainActor
final class BootstrapLookupFlow: LookupFlow {
    func lookup(_ capture: LookupCapture) async {
        let displays = capture.displays.map {
            "\($0.displayID): \($0.image.width)×\($0.image.height) px"
        }.joined(separator: ", ")
        writeToConsole(
            "Captured \(capture.displays.count) display(s) [\(displays)]; pointer on display \(capture.pointerDisplayID), in image: \(String(describing: capture.pointerInImage))."
        )
    }
}
