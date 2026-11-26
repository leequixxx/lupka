import LupkaCore
import Testing

@Test
func coreInfoComesFromRust() {
    let info = coreInfo()

    #expect(info.name == "Lupka")
    #expect(info.version == "0.1.0")
}
