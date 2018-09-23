//
//  ScoredElement.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/21/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import VinXML

extension VinXML.XMLNode {
    
    /**
     * Store the content score as an XML attribute so that it can be used by
     * XPath queries and because VinXML classes shouldn't maintain state as
     * it can get lost depending on how the XMLNode was accessed.
     */
    var score: Int {
        
        get {
            if let score = self.attributes[ContentExtractor.scoreAttrName] {
                return Int(score)!
            }
            return 0
        }
        
        set {
            
            guard newValue > 0 else {
                return
            }
            
            self.attributes[ContentExtractor.scoreAttrName] = String(newValue)
            
        }
        
    }
    
    var scoreCounter: Double {
        
        get {
            if let score = self.attributes[ContentExtractor.scoreCounterAttrName] {
                return Double(score)!
            }
            return 0
        }
        
        set {
            
            guard newValue > 0 else {
                return
            }
            
            self.attributes[ContentExtractor.scoreCounterAttrName] = String(newValue)
            
        }
        
    }

    var blockElement: Bool {
        guard let name = self.name else {
            return false
        }
        return ["html", "body", "head", "meta", "p", "h1", "h2", "h3", "h4", "h5", "h6", "ol", "ul",
                "pre", "address", "blockquote", "dl", "div", "fieldset", "form", "hr", "noscript", "table",
                "main", "mark", "summary", "time", "figure", "figcaption", "details",
                "article", "section", "aside", "footer", "nav", "br", "img", "a"].contains(name)
        
    }
    
    func hasHighLinkDensity() throws -> Bool {
        
        let links = try self.query(xpath: ".//a | .//*[@onclick]")
        
        if !links.isEmpty {
            let wordCount = self.content?
                .components(separatedBy: .whitespacesAndNewlines).filter({$0 != ""}).count ?? 0
            let linkWordCount = links.map( {$0.text?.components(separatedBy: .whitespacesAndNewlines).count })
                .reduce(0, { $0 + ($1 ?? 0) })
            // We need to have at least twice as many words as link words
            let highLinkDensity = (linkWordCount * 2) > wordCount
            return highLinkDensity
        }
        
        return false
        
    }
    
}
