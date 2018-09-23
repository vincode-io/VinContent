//

import Foundation
import XCTest

@testable import VinContent

class VinContentBaseTest: XCTestCase {

    var testHandle: String? = nil
    var expectedTitle: String? = nil
    var expectedPublisher: String? = nil
    var expectedPublishDate: Date? = nil
    var expectedByline: String? = nil
    var expectedDescription: String? = nil
    var expectedSource: String? = nil
    
    func commonTest() {
        
        let bundleURL = Bundle(for: type(of: self)).resourceURL
        let inputURL = bundleURL!.appendingPathComponent("\(testHandle!)-input.html")
        
        let article = try! ContentExtractor.extractArticle(from: inputURL)
        
        XCTAssertEqual(expectedTitle, article.title)
        XCTAssertEqual(expectedPublisher, article.publisher)
        XCTAssertEqual(expectedPublishDate, article.publishDate)
        XCTAssertEqual(expectedByline, article.byline)
        XCTAssertEqual(expectedDescription, article.description)
        XCTAssertEqual(expectedSource, article.source?.absoluteString)
        
        let expectedURL = bundleURL!.appendingPathComponent("\(testHandle!)-expected.html")
        let expectedContent = try! String(contentsOf: expectedURL)

        XCTAssertEqual(expectedContent, article.wrappedContent)
        
    }
    
}
