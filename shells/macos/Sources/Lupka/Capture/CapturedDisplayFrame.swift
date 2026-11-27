import CoreGraphics

struct DisplayGeometry: Equatable {
    let displayID: CGDirectDisplayID
    let displayFrame: CGRect
}

struct CapturedDisplayFrame {
    let image: CGImage
    let displayID: CGDirectDisplayID
    let displayFrame: CGRect
}
