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
    
    private static let keepTagNames: Set = ["body", "html", "article", "math"]
    private static let scrubTagNames: Set = ["footer", "script", "noscript", "style", "form", "nav"]
    private static let scrubRegEx = try? NSRegularExpression(pattern: "^side$|^sidebar$|combx|retweet|mediaarticlerelated|menucontainer|" +
        "navbar|comment(?!ed)|PopularQuestions|contact|footer|Footer|footnote|cnn_strycaptiontxt|" +
        "links|meta$|scroll(?!able)|shoutbox|sponsor|tags|socialnetworking|socialNetworking|" +
        "cnnStryHghLght|cnn_stryspcvbx|^inset$|pagetools|post-attributes|welcome_form|contentTools2|" +
        "the_answers|remember-tool-tip|communitypromo|promo_holder|runaroundLeft|^subscribe$|vcard|" +
        "articleheadings|date|^print$|popup|author-dropdown|tools|socialtools|byline|konafilter|" +
        "KonaFilter|breadcrumbs|^fn$|wp-caption-text|overlay|dont-print|signup|^jp-relatedposts$|" +
        "robots-nocontent|RelatedCoverage", options: .caseInsensitive)
    
    private var articleTitle: String?
    
    init(articleTitle: String?) {
        self.articleTitle = articleTitle
    }
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
        
        if let elementName = node.name {
            
            // Remove tags by name
            if ContentPreScrubbingVisitor.scrubTagNames.contains(elementName) {
                try remove(node)
                return false
            }

            // For some reason people put stuff in these tags that triggers our regex checks.
            // There is never a reason to remove one of these tags, so give it a pass.
            if ContentPreScrubbingVisitor.keepTagNames.contains(elementName) {
                return true
            }
            
        }
        
        // Only scrub block elements
        if !node.blockElement {
            return true
        }
        
        // Convert font tags to spans
        if node.name == "font" {
            node.name = "span"
        }
        
        // Make sure that there aren't any wacky inline font size things
        node.attributes["style"] = nil
        
        // Data based images are usually doing some weird layout stuff.
        if node.name == "img", let imgSrc = node.attributes["src"]?.lowercased() {
            if imgSrc.starts(with: "data:") {
                try remove(node)
                return false
            }
            
        }

        if let attrContent = node.attributes["id"] {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        if let attrContent = node.attributes["name"] {
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        if let attrContent = node.attributes["class"] {
            // This is a hack to let Reddit mobile pages work
            if attrContent == "CommentsPage" {
                return true
            }
            if ContentPreScrubbingVisitor.scrubRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                try remove(node)
                return false
            }
        }
        
        // We are assuming that the title is being displayed by using the
        // extracted metadata.
        if node.name == "h1" && node.content == articleTitle {
            try remove(node)
            return false
        }
        
        if try node.hasHighLinkDensity() {
            try remove(node)
            return false
        }
        
        return true
        
    }
    
    private func remove(_ node: VinXML.XMLNode) throws {
//        if let classValue = node.attributes["class"] {
//            print("--- prescrubber removing --- \(node.name ?? "n/a") *** \(classValue)")
//        } else {
//            print("--- prescrubber removing --- \(node.name ?? "n/a")")
//        }
//        print(node.html ?? "n/a")
        try node.remove()
    }
    
}
