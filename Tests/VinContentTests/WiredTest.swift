//  Copyright © 2018 Vincode. All rights reserved.

import XCTest

@testable import VinContent

class WiredTest: VinContentBaseTest {
    
    override func setUp() {
        testHandle = "wired"
        expectedTitle = "Now We Know Why Microsoft Bought LinkedIn"
        expectedPublisher = "WIRED"
        expectedPublishDate = nil
        expectedByline = "Jessi Hempel"
        expectedDescription = "Satya Nadella is on a crusade to change Microsoft’s reputation, and hiring Reid Hoffman is his money move."
        expectedSource = "https://www.wired.com/2017/03/now-we-know-why-microsoft-bought-linkedin/"
    }
    
    func testWired() {
        super.commonTest()
    }
    
}
