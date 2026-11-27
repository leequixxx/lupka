import CoreGraphics
import Testing

@testable import Lupka

@MainActor
final class StubCapturer: ScreenCapturing {
    private let result: Result<CapturedFrame, Error>
    private(set) var callCount = 0

    init(result: Result<CapturedFrame, Error>) {
        self.result = result
    }

    func capture() async throws -> CapturedFrame {
        callCount += 1
        return try result.get()
    }
}

@MainActor
final class RecordingLookupFlow: LookupFlow {
    private(set) var frames: [CapturedFrame] = []

    func lookup(_ frame: CapturedFrame) async {
        frames.append(frame)
    }
}

@Test @MainActor
func coordinatorPassesCapturedFrameToLookupFlow() async throws {
    let frame = CapturedFrame(
        displays: [
            CapturedDisplayFrame(
                image: try makeImage(width: 2, height: 2),
                displayID: 7,
                displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
            ),
            CapturedDisplayFrame(
                image: try makeImage(width: 2, height: 2),
                displayID: 8,
                displayFrame: CGRect(x: 1_440, y: 0, width: 1_440, height: 900)
            )
        ],
        pointer: CGPoint(x: 0.5, y: 0.5),
        pointerDisplayID: 7
    )
    let capturer = StubCapturer(result: .success(frame))
    let lookupFlow = RecordingLookupFlow()
    let coordinator = LookupCoordinator(
        capturer: capturer,
        lookupFlow: lookupFlow,
        onError: { _ in Issue.record("Unexpected capture error") }
    )

    await coordinator.handleHotKey()

    #expect(capturer.callCount == 1)
    #expect(lookupFlow.frames.count == 1)
    #expect(lookupFlow.frames.first?.pointerDisplayID == 7)
    #expect(lookupFlow.frames.first?.displays.count == 2)
    #expect(lookupFlow.frames.first?.displays.first?.displayID == 7)
    #expect(lookupFlow.frames.first?.displays.last?.displayID == 8)
}

@Test @MainActor
func coordinatorReportsCaptureErrorsAndRecovers() async throws {
    let capturer = StubCapturer(result: .failure(ScreenCaptureError.permissionDenied))
    let lookupFlow = RecordingLookupFlow()
    var reportedMessages: [String] = []
    let coordinator = LookupCoordinator(
        capturer: capturer,
        lookupFlow: lookupFlow,
        onError: { reportedMessages.append($0.localizedDescription) }
    )

    await coordinator.handleHotKey()
    await coordinator.handleHotKey()

    #expect(capturer.callCount == 2)
    #expect(lookupFlow.frames.isEmpty)
    #expect(reportedMessages.count == 2)
    #expect(reportedMessages.first?.contains("terminal") == true)
    #expect(reportedMessages.first?.contains("Screen Recording") == true)
}

@Test @MainActor
func carbonHotKeyRegistersAndUnregisters() throws {
    let hotKey = CarbonHotKey(onPress: {})
    defer { hotKey.stop() }

    try hotKey.start()
    #expect(hotKey.isRegistered)

    hotKey.stop()
    #expect(!hotKey.isRegistered)

    try hotKey.start()
    #expect(hotKey.isRegistered)
}
