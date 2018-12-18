//
//  XPathQueryTests.swift
//  VinFoundation
//
//  Created by Maurice Parker on 1/30/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import XCTest
@testable import VinContent

class XPathQueryTests: XMLBaseTest {
    
    func testElementContent() {
        
        do {
            
            let doc = try loadHTHLDoc()
            
            let xpath = "//*[@class='entry-title']"
            let node = try doc.queryFirst(xpath: xpath)
            XCTAssertNotNil(node)
            
            XCTAssertEqual(node?.content, "Company")
            
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func testPropertyContent() {
        
        do {
            
            let doc = try loadHTHLDoc()
            
            let xpath = "//*[@property='og:description']"
            let node = try doc.queryFirst(xpath: xpath)
            XCTAssertNotNil(node)
            
            let contentAttr = node?.attributes["content"]
            XCTAssertNotNil(contentAttr)

            XCTAssertEqual(contentAttr, "Mobile and Web Development")
            
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    func testNameSpaceQuery() throws {
        
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
        "<package xmlns=\"http://www.idpf.org/2007/opf\" version=\"3.0\" xml:lang=\"en\" unique-identifier=\"pub-id\">" +
        "<metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">" +
        "<dc:title id=\"title\">VinXML</dc:title>" +
        "<dc:creator id=\"creator\">Maurice C Parker</dc:creator>" +
        "</metadata>" +
        "</package>"
        
        let doc = try VinContent.XMLDocument(xml: xml)
        doc?.registerXPathNamespace(prefix: "dc", url: "http://purl.org/dc/elements/1.1/")
        
        let dcTitle = try doc?.queryFirst(xpath: "//*/dc:title")
        XCTAssertNotNil(dcTitle?.content)
        XCTAssertEqual("VinXML", dcTitle!.content!)
        
        let dcCreator = try doc?.queryFirst(xpath: "//*/dc:creator")
        XCTAssertNotNil(dcCreator?.content)
        XCTAssertEqual("Maurice C Parker", dcCreator!.content!)
        
    }
    
}
