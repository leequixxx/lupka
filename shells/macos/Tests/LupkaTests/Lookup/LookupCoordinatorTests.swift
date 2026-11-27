import CoreGraphics
import Testing

@testable import Lupka

@MainActor
final class StubCapturer: ScreenCapturing {
    private let result: Result<[CapturedDisplayFrame], Error>
    private(set) var callCount = 0

    init(result: Result<[CapturedDisplayFrame], Error>) {
        self.result = result
    }

    func capture() async throws -> [CapturedDisplayFrame] {
        callCount += 1
        return try result.get()
    }
}

@MainActor
final class StubPointerLocator: PointerLocating {
    private let snapshot: PointerSnapshot

    init(displayID: CGDirectDisplayID) {
        snapshot = PointerSnapshot(position: CGPoint(x: 0.5, y: 0.5), displayID: displayID)
    }

    func pointer() throws -> PointerSnapshot {
        snapshot
    }
}

@MainActor
final class RecordingLookupFlow: LookupFlow {
    private(set) var captures: [LookupCapture] = []

    func lookup(_ capture: LookupCapture) async {
        captures.append(capture)
    }
}

@Test @MainActor
func coordinatorPassesDisplayFramesAndPointerToLookupFlow() async throws {
    let displays = [
        try makeDisplay(displayID: 7),
        try makeDisplay(displayID: 8, x: 1_440),
    ]
    let capturer = StubCapturer(result: .success(displays))
    let lookupFlow = RecordingLookupFlow()
    let coordinator = LookupCoordinator(
        capturer: capturer,
        pointerLocator: StubPointerLocator(displayID: 7),
        lookupFlow: lookupFlow,
        onError: { _ in Issue.record("Unexpected capture error") }
    )

    await coordinator.handleHotKey()

    #expect(capturer.callCount == 1)
    #expect(lookupFlow.captures.count == 1)
    #expect(lookupFlow.captures.first?.pointerDisplayID == 7)
    #expect(lookupFlow.captures.first?.displays.map(\.displayID) == [7, 8])
}

@Test @MainActor
func coordinatorReportsCaptureErrorsAndRecovers() async {
    let capturer = StubCapturer(result: .failure(ScreenCaptureError.permissionDenied))
    let lookupFlow = RecordingLookupFlow()
    var reportedMessages: [String] = []
    let coordinator = LookupCoordinator(
        capturer: capturer,
        pointerLocator: StubPointerLocator(displayID: 7),
        lookupFlow: lookupFlow,
        onError: { reportedMessages.append($0.localizedDescription) }
    )

    await coordinator.handleHotKey()
    await coordinator.handleHotKey()

    #expect(capturer.callCount == 2)
    #expect(lookupFlow.captures.isEmpty)
    #expect(reportedMessages.count == 2)
    #expect(reportedMessages.first?.contains("terminal") == true)
    #expect(reportedMessages.first?.contains("Screen Recording") == true)
}

@Test @MainActor
func coordinatorRejectsLookupWhenPointerDisplayIsNotCaptured() async throws {
    let capturer = StubCapturer(result: .success([try makeDisplay(displayID: 8)]))
    let lookupFlow = RecordingLookupFlow()
    var reportedMessages: [String] = []
    let coordinator = LookupCoordinator(
        capturer: capturer,
        pointerLocator: StubPointerLocator(displayID: 7),
        lookupFlow: lookupFlow,
        onError: { reportedMessages.append($0.localizedDescription) }
    )

    await coordinator.handleHotKey()

    #expect(lookupFlow.captures.isEmpty)
    #expect(reportedMessages == [LookupCaptureError.pointerDisplayNotCaptured.localizedDescription])
}

private func makeDisplay(
    displayID: CGDirectDisplayID,
    x: CGFloat = 0
) throws -> CapturedDisplayFrame {
    CapturedDisplayFrame(
        image: try makeImage(width: 2, height: 2),
        displayID: displayID,
        displayFrame: CGRect(x: x, y: 0, width: 1_440, height: 900)
    )
}
