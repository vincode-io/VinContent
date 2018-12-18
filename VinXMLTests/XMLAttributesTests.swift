//
//  XMLAttributeTests.swift
//  VinXML
//
//  Created by Maurice Parker on 3/7/17.
//
//

import XCTest
@testable import VinContent

class XMLAttributesTests: XMLBaseTest {
    
    

    func testAttributes() throws {
        
        let doc = try XMLDocument(html: testHTML)
        
        let firstPara = try doc?.queryFirst(xpath: "//*[@id='first']")
        XCTAssertNotNil(firstPara)
        
        firstPara?.attributes["newAtt"] = "newValue"
        var firstParaAgain = try doc?.queryFirst(xpath: "//*[@newAtt='newValue']")
        XCTAssertNotNil(firstParaAgain)

        firstPara?.attributes["newAtt"] = "anotherValue"
        firstParaAgain = try doc?.queryFirst(xpath: "//*[@newAtt='anotherValue']")
        XCTAssertNotNil(firstParaAgain)
        
        firstPara?.attributes["newAtt"] = nil
        firstParaAgain = try doc?.queryFirst(xpath: "//*[@newAtt='anotherValue']")
        XCTAssertNil(firstParaAgain)
        
    }
    
}
