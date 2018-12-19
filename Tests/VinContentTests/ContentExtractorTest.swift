//

import Foundation
import XCTest

@testable import VinContent

class ContentExtractorTest: XCTestCase {
    
    func testInitialParsable() {

        var contentExractor = ContentExtractor(url: URL(string: "http://twitter.com/rss.xml")!)
        XCTAssertEqual(ContentExtractorState.unableToParse, contentExractor.state)

        contentExractor = ContentExtractor(url: URL(string: "https://vincode.io/feeds")!)
        XCTAssertEqual(ContentExtractorState.ready, contentExractor.state)

        contentExractor = ContentExtractor(url: URL(string: "https://vimeo.com")!)
        XCTAssertEqual(ContentExtractorState.unableToParse, contentExractor.state)

    }
    
}
