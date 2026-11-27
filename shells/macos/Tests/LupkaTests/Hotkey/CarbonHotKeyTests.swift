import Testing

@testable import Lupka

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
