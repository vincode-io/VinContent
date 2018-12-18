//

import XCTest

@testable import VinContent

class MacworldTest: VinContentBaseTest {
    
    override func setUp() {
        testHandle = "macworld"
        expectedTitle = "macOS Mojave and the future of the Mac"
        expectedPublisher = "Macworld"
        expectedPublishDate = nil
        expectedByline = nil
        expectedDescription = "While one of Mojave\'s signature features involves running iOS apps on the Mac, Dan Moren thinks the latest macOS update proves Apple is still interested in keeping the Mac a tool for power users."
        expectedSource = "https://www.macworld.com/article/3309580/os-x/article.html"
    }
    
    func testMacworld() {
        super.commonTest()
    }
    
}
