//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

public struct ContentArticle {
    
    public var title: String?
    public var publisher: String?
    public var byline: String?
    public var description: String?
    public var source: URL?
    public var publishDate: Date?
    public var image: URL?
    public var length: Int?
    public var mangledDocument: XMLDocument?
    public var content: [XMLElement]?
    
    public var wrappedContent: String? {
        
        guard content != nil && content!.count > 0 else {
            return nil
        }
        
        let xhtml = content!.reduce("") { $0 + $1.xmlString }
        return "<div>\(xhtml)</div>"
        
    }
    
}
