import CoreGraphics
import Testing

@testable import Lupka

@Test @MainActor
func appKitPointerConvertsToTopLeftCoordinates() {
    let primaryDisplayPoint = PointerLocator.coreGraphicsPoint(
        fromAppKitPoint: CGPoint(x: 100, y: 100),
        primaryScreenHeight: 1_080
    )
    let displayAbovePoint = PointerLocator.coreGraphicsPoint(
        fromAppKitPoint: CGPoint(x: 100, y: 1_200),
        primaryScreenHeight: 1_080
    )

    #expect(primaryDisplayPoint == CGPoint(x: 100, y: 980))
    #expect(displayAbovePoint == CGPoint(x: 100, y: -120))
}
