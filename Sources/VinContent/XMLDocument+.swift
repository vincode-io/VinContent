//  Copyright © 2017 Vincode. All rights reserved.

extension XMLDocument {

    func metaTagContent(forName tagName: String) throws -> String? {
        let xpath = "//*/meta[@name='\(tagName)' or @property='\(tagName)']"
        if let element = try self.firstNode(forXPath: xpath) as? XMLElement {
            return element.attribute(forName: "content")?.stringValue?.trimmed()
        }
        return nil
    }
    
}
