//
//  XMLDocument+VinCE.swift
//  VinFoundation
//
//  Created by Maurice Parker on 3/18/17.
//
//

extension VinContent.XMLDocument {

    func metaTagContent(forName tagName: String) throws -> String? {
        let xpath = "//*/meta[@name='\(tagName)' or @property='\(tagName)']"
        if let node = try self.queryFirst(xpath: xpath) {
            return node.attributes["content"]?.trimmed()
        }
        return nil
    }
    
}
