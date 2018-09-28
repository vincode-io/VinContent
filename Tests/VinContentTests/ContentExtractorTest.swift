//

import Foundation
import XCTest

@testable import VinContent

class ContentExtractorTest: XCTestCase {
    
    func testInitialParsable() {

        var contentExractor = ContentExtractor(URL(string: "http://twitter.com/rss.xml")!)
        XCTAssertEqual(ContentExtractorState.unableToParse, contentExractor.state)

        contentExractor = ContentExtractor(URL(string: "https://vincode.io/feeds")!)
        XCTAssertEqual(ContentExtractorState.ready, contentExractor.state)

        contentExractor = ContentExtractor(URL(string: "https://vimeo.com")!)
        XCTAssertEqual(ContentExtractorState.unableToParse, contentExractor.state)

    }
    
}
