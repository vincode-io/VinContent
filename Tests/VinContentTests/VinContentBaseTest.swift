//

import Foundation
import XCTest

@testable import VinContent

class TestDelegate: ContentExtractorDelegate {
    
    var baseTest: VinContentBaseTest!
    
    init(baseTest: VinContentBaseTest) {
        self.baseTest = baseTest
    }
    
    func contentExtractionDidFail(with error: Error) {
        baseTest.errorResult = error
        baseTest.expectation!.fulfill()
    }
    
    func contentExtractionDidComplete(article: ContentArticle) {
        baseTest.articleResult = article
        baseTest.expectation!.fulfill()
    }
    
}

class VinContentBaseTest: XCTestCase {

    var testHandle: String? = nil
    var expectedTitle: String? = nil
    var expectedPublisher: String? = nil
    var expectedPublishDate: Date? = nil
    var expectedByline: String? = nil
    var expectedDescription: String? = nil
    var expectedSource: String? = nil

    var expectation: XCTestExpectation? = nil
    var errorResult: Error? = nil
    var articleResult: ContentArticle? = nil
    
    func commonTest() {
        
        expectation = XCTestExpectation(description: "Load and parse article")
        
        let delegate = TestDelegate(baseTest: self)
        
        let bundleURL = Bundle(for: type(of: self)).resourceURL
        let inputURL = bundleURL!.appendingPathComponent("\(testHandle!)-input.html")
        
        let contentExtractor = ContentExtractor(url: inputURL)
        contentExtractor.delegate = delegate
        contentExtractor.process()
        
        wait(for: [expectation!], timeout: 5.0)
        
        XCTAssertEqual(expectedTitle, articleResult!.title)
        XCTAssertEqual(expectedPublisher, articleResult!.publisher)
        XCTAssertEqual(expectedPublishDate, articleResult!.publishDate)
        XCTAssertEqual(expectedByline, articleResult!.byline)
        XCTAssertEqual(expectedDescription, articleResult!.description)
        XCTAssertEqual(expectedSource, articleResult!.source?.absoluteString)
        
        let expectedURL = bundleURL!.appendingPathComponent("\(testHandle!)-expected.html")
        let expectedContent = try! String(contentsOf: expectedURL)

        XCTAssertEqual(expectedContent, articleResult!.htmlContent)
        
    }
    
}
