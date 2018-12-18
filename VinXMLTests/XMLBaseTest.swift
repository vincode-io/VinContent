//
//  XMLLib2BaseTest.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/4/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import XCTest
@testable import VinContent

class XMLBaseTest: XCTestCase {

    static var bundle: Bundle {
        return Bundle(for: XMLBaseTest.self)
    }
    
    let testHTML = "<html><head><title>Title</title></head><body>"
        + "<h1>A heading 1 title</h1>"
        + "<p id=\"first\">The first paragraph."
        + "  <span id=\"p1span1\">Span block 1</span>"
        + "  <span id=\"p1span2\">Span block 2</span>"
        + "  <span id=\"p1span3\">Span block 3</span>"
        + "</p>"
        + "<p id=\"second\">The second paragraph.</p>"
        + "<p id=\"third\">The third paragraph."
        + "  <span id=\"p3span1\">Span block 1</span>"
        + "  <span id=\"p3span2\">Span block 2</span>"
        + "  <span id=\"p3span3\">Span block 3</span>"
        + "</p>"
        + "</body></html>"
    
    func loadHTHLDoc() throws -> VinContent.XMLDocument {
        let htmlLocation = XMLBaseTest.bundle.url(forResource: "vincode.io", withExtension: "html")
        guard let html = try? String(contentsOf: htmlLocation!) else {
            fatalError()
        }
        return try XMLDocument(html: html)!
    }
    
}
