import CoreGraphics

enum DisplaySelection: Equatable, Sendable {
    case all
    case only(Set<CGDirectDisplayID>)

    func includes(_ displayID: CGDirectDisplayID) -> Bool {
        switch self {
        case .all:
            true
        case let .only(displayIDs):
            displayIDs.contains(displayID)
        }
    }
}

struct CaptureConfiguration: Equatable, Sendable {
    static let `default` = CaptureConfiguration()

    let displays: DisplaySelection

    init(displays: DisplaySelection = .all) {
        self.displays = displays
    }

    func selectDisplays(_ displays: [DisplayGeometry]) -> [DisplayGeometry] {
        displays
            .filter { self.displays.includes($0.displayID) }
            .sorted { first, second in
                if first.displayFrame.minY != second.displayFrame.minY {
                    return first.displayFrame.minY < second.displayFrame.minY
                }
                if first.displayFrame.minX != second.displayFrame.minX {
                    return first.displayFrame.minX < second.displayFrame.minX
                }
                return first.displayID < second.displayID
            }
    }
}
