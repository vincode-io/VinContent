//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

class ContentPreScrubbingVisitor: Visitor {
    
    static let scrubTagNames: Set = ["head", "footer", "script", "noscript", "style", "svg"]
    static let scrubRegEx = try? NSRegularExpression(pattern: "^side$|^sidebar$|combx|retweet|mediaarticlerelated|menucontainer|" +
        "navbar|comment(?!ed)|PopularQuestions|contact|footer|Footer|footnote|cnn_strycaptiontxt|" +
        "links|meta$|scroll(?!able)|shoutbox|sponsor|tags|socialnetworking|socialNetworking|" +
        "cnnStryHghLght|cnn_stryspcvbx|^inset$|pagetools|post-attributes|welcome_form|contentTools2|" +
        "the_answers|remember-tool-tip|communitypromo|promo_holder|runaroundLeft|^subscribe$|vcard|" +
        "articleheadings|date|^print$|popup|author-dropdown|tools|socialtools|byline|konafilter|" +
        "KonaFilter|breadcrumbs|^fn$|wp-caption-text|overlay|dont-print", options: .caseInsensitive)
    
    func visit(host: VisitorHost) throws -> Bool {
        
        guard let element = host as? XMLElement else {
            return false
        }
        
        // Remove tags by name
        if ContentPreScrubbingVisitor.scrubTagNames.contains(element.name!) {
            try remove(element)
            return false
        }

        // For some reason people put stuff in the body tag that triggers our regex checks.
        // There is never a reason to remove the whole body, so give it a pass.
        if element.name == "body" || element.name == "html" {
            return true
        }
        
        // Only scrub block elements
        if !element.blockElement {
            return true
        }
        
        // Convert font tags to spans
        if element.name == "font" {
            element.name = "span"
        }
        
        if let attrContent = element.attribute(forName: "id")?.stringValue {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(element)
                return false
            }
        }
        
        if let attrContent = element.attribute(forName: "name")?.stringValue {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(element)
                return false
            }
        }
        
        if let attrContent = element.attribute(forName: "class")?.stringValue {
            // This is a hack to let Reddit mobile pages work
            if attrContent == "CommentsPage" {
                return true
            }
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(element)
                return false
            }
        }
        
        return true
        
    }
    
    private func remove(_ node: XMLNode) throws {
        guard let parentElement = node.parent as? XMLElement else {
            assertionFailure("Invalid element to remove.")
            return
        }
        guard let nodeIndex = parentElement.children?.firstIndex(of: node) else {
            assertionFailure("That node should have been in there...")
            return
        }
        parentElement.removeChild(at: nodeIndex)
    }
    
}
