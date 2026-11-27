import Foundation

@MainActor
protocol LookupFlow {
    func lookup(_ capture: LookupCapture) async
}

@MainActor
final class LookupCoordinator {
    private let capturer: any ScreenCapturing
    private let pointerLocator: any PointerLocating
    private let lookupFlow: any LookupFlow
    private let onError: (Error) -> Void
    private var isLookupInProgress = false

    init(
        capturer: any ScreenCapturing,
        pointerLocator: any PointerLocating,
        lookupFlow: any LookupFlow,
        onError: @escaping (Error) -> Void
    ) {
        self.capturer = capturer
        self.pointerLocator = pointerLocator
        self.lookupFlow = lookupFlow
        self.onError = onError
    }

    func handleHotKey() async {
        guard !isLookupInProgress else {
            return
        }
        isLookupInProgress = true
        defer { isLookupInProgress = false }

        do {
            let pointer = try pointerLocator.pointer()
            let displays = try await capturer.capture()
            guard displays.contains(where: { $0.displayID == pointer.displayID }) else {
                throw LookupCaptureError.pointerDisplayNotCaptured
            }
            let capture = LookupCapture(
                displays: displays,
                pointer: pointer.position,
                pointerDisplayID: pointer.displayID
            )
            await lookupFlow.lookup(capture)
        } catch {
            onError(error)
        }
    }
}
