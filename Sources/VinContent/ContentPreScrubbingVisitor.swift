//
//  ContentScrubbingVisitor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/14/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import VinXML

class ContentPreScrubbingVisitor: XMLVisitor {
    
    static let scrubTagNames: Set = ["head", "footer", "script", "noscript", "style", "svg"]
    static let scrubRegEx = try? NSRegularExpression(pattern: "^side$|^sidebar$|combx|retweet|mediaarticlerelated|menucontainer|" +
        "navbar|comment(?!ed)|PopularQuestions|contact|footer|Footer|footnote|cnn_strycaptiontxt|" +
        "links|meta$|scroll(?!able)|shoutbox|sponsor|tags|socialnetworking|socialNetworking|" +
        "cnnStryHghLght|cnn_stryspcvbx|^inset$|pagetools|post-attributes|welcome_form|contentTools2|" +
        "the_answers|remember-tool-tip|communitypromo|promo_holder|runaroundLeft|^subscribe$|vcard|" +
        "articleheadings|date|^print$|popup|author-dropdown|tools|socialtools|byline|konafilter|" +
        "KonaFilter|breadcrumbs|^fn$|wp-caption-text|overlay|dont-print", options: .caseInsensitive)
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
        
        // Remove tags by name
        if ContentPreScrubbingVisitor.scrubTagNames.contains(node.name!) {
            try remove(node)
            return false
        }

        // For some reason people put stuff in the body tag that triggers our regex checks.
        // There is never a reason to remove the whole body, so give it a pass.
        if node.name == "body" || node.name == "html" {
            return true
        }
        
        // Only scrub block elements
        if !node.blockElement {
            return true
        }
        
        // Convert font tags to spans
        if node.name == "font" {
            node.name = "span"
        }
        
        // Feature: Collapse multiple br tags into a single p tag (not implemented)
        //
        // The jury is out on if this is still useful or is legacy cruft.  It is a pain
        // to implement elequently and I'm not convinced of its necessity.  I'm going to 
        // have to see this one in the wild before I implement it. -Maurice

        if let attrContent = node.attributes["id"] {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.characters.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        if let attrContent = node.attributes["name"] {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.characters.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        if let attrContent = node.attributes["class"] {
            // This is a hack to let Reddit mobile pages work
            if attrContent == "CommentsPage" {
                return true
            }
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.characters.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        return true
        
    }
    
    private func remove(_ node: VinXML.XMLNode) throws {
//        if let classValue = node.attributes["class"] {
//            print("--- prescrubber removing --- \(node.name ?? "n/a") *** \(classValue)")
//        } else {
//            print("--- prescrubber removing ---\(node.name ?? "n/a")")
//        }
        try node.remove()
    }
}
