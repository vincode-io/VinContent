//
//  ExtractedArticle.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/4/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import VinXML

public struct ExtractedArticle {
    
    public var title: String?
    public var publisher: String?
    public var byline: String?
    public var description: String?
    public var source: URL?
    public var sourceHTML: String?
    public var publishDate: Date?
    public var image: URL?
    public var length: Int?
    public var mangledDocument: VinXML.XMLDocument?
    public var content: [VinXML.XMLNode]?
    
    public var wrappedContent: String? {
        
        guard content != nil && content!.count > 0 else {
            return nil
        }
        
        var xhtml = ""
        for node in content! {
            xhtml.append(node.html ?? "")
        }
        
        return "<div>\(xhtml)</div>"
        
    }
    
}
