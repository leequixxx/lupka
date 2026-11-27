import Foundation

@MainActor
protocol LookupFlow {
    func lookup(_ frame: CapturedFrame) async
}

@MainActor
final class LookupCoordinator {
    private let capturer: any ScreenCapturing
    private let lookupFlow: any LookupFlow
    private let onError: (Error) -> Void
    private var isCapturing = false

    init(
        capturer: any ScreenCapturing,
        lookupFlow: any LookupFlow,
        onError: @escaping (Error) -> Void
    ) {
        self.capturer = capturer
        self.lookupFlow = lookupFlow
        self.onError = onError
    }

    func handleHotKey() async {
        guard !isCapturing else {
            return
        }
        isCapturing = true
        defer { isCapturing = false }

        do {
            let frame = try await capturer.capture()
            await lookupFlow.lookup(frame)
        } catch {
            onError(error)
        }
    }
}
