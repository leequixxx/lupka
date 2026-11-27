import CoreGraphics
import Testing

@testable import Lupka

@Test
func allDisplaySelectionUsesDesktopOrder() {
    let configuration = CaptureConfiguration(displays: .all)

    let selected = configuration.selectDisplays([mainDisplay, leftDisplay, aboveDisplay])

    #expect(selected.map(\.displayID) == [3, 2, 1])
}

@Test
func onlyDisplaySelectionReturnsRequestedDisplays() {
    let configuration = CaptureConfiguration(displays: .only([1, 3]))

    let selected = configuration.selectDisplays([mainDisplay, leftDisplay, aboveDisplay])

    #expect(selected.map(\.displayID) == [3, 1])
}

@Test
func emptyDisplaySelectionReturnsNoDisplays() {
    let configuration = CaptureConfiguration(displays: .only([]))

    let selected = configuration.selectDisplays([mainDisplay, leftDisplay, aboveDisplay])

    #expect(selected.isEmpty)
}

private let mainDisplay = DisplayGeometry(
    displayID: 1,
    displayFrame: CGRect(x: 0, y: 0, width: 1_440, height: 900)
)
private let leftDisplay = DisplayGeometry(
    displayID: 2,
    displayFrame: CGRect(x: -1_440, y: 0, width: 1_440, height: 900)
)
private let aboveDisplay = DisplayGeometry(
    displayID: 3,
    displayFrame: CGRect(x: 0, y: -900, width: 1_440, height: 900)
)
