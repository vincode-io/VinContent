//  Copyright © 2018 Vincode. All rights reserved.

import XCTest

@testable import VinContent

class VinBookCoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testContentExtraction() {
        
        let url = Bundle(for: type(of: self)).resourceURL
        let source = url!.appendingPathComponent("backchannel.html")
        
        let article = try! ContentExtractor.extractArticle(from: source)
        
        XCTAssertEqual("Now We Know Why Microsoft Bought LinkedIn", article.title)
        XCTAssertEqual("Backchannel", article.publisher)
        XCTAssertEqual("Jessi Hempel", article.byline)
        XCTAssertEqual("Six months after Microsoft announced plans to pay more than $26 billion for LinkedIn, we now know even more about why the career-focused social networking site was so valuable. Today, Microsoft…", article.description)
        XCTAssertEqual("https://backchannel.com/now-we-know-why-microsoft-bought-linkedin-dad742b3dd87", article.source?.absoluteString)

        let output = url!.appendingPathComponent("backchannel-result.html")
        try! article.wrappedContent?.write(to: output, atomically: true, encoding: .utf16)
        
    }
    
}
