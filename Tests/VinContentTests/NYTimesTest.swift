//

import XCTest

@testable import VinContent

class NYTimesTest: VinContentBaseTest {
    
    override func setUp() {
        testHandle = "nytimes"
        expectedTitle = "Iran’s Revolutionary Guards, Humiliated by Attack, Vow to Retaliate"
        expectedPublisher = nil // should be "www.nytimes.com"
        expectedPublishDate = nil
        expectedByline = nil
        expectedDescription = "After an attack that killed 25 people, including 12 members of the elite unit, Iran promises to strike back against the United States and its gulf allies."
        expectedSource = "https://www.nytimes.com/2018/09/24/world/middleeast/iran-attack-military-parade.html"
    }
    
    func testTheTimes() {
        super.commonTest()
    }
    
}
