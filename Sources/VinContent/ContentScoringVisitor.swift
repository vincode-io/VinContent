//
//  ContentScoringVisitor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/16/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import VinXML

class ContentScoringVisitor: XMLVisitor {
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
        
        // If this node is mostly links, don't score it
        if try node.hasHighLinkDensity() {
            return true
        }

        guard let elementName = node.name else {
            return true
        }
        
        var upscore = 0
        
        // Boost headings since they aren't usually loaded with junk, but 
        // still sometimes don't have conversational words that would be picked up
        // with the stop words.
        if ["h1", "h2", "h3", "h4", "h5", "h6"].contains(elementName) {
            upscore = 3
        }

        // We are going to boost math elements assuming that advertisers won't abuse
        // this tag.  Since there are may not be words, let's max them.
        if elementName == "math" {
            upscore = ContentExtractor.scoreThreshold
        }
        
        // Boost images since they will never have stop words and we want to pick them
        // up if they are part of a cluster.
        if elementName == "img",
            let width = Int(node.attributes["width"] ?? "0"),
            let height = Int(node.attributes["height"] ?? "0") {
            
            upscore = upscore + (width / 100)
            upscore = upscore + (height / 100)
            
        }
        
        // Bump the score based on the number of conversational words found
        if let elementText = node.text {
            let contentStopWords = StopWords.countStopWords(elementText)
            upscore = upscore + contentStopWords
        }

        var elementToScore: XMLNode? = node
        while elementToScore != nil && !elementToScore!.blockElement {
            elementToScore = elementToScore!.parent
        }
        
        guard elementToScore != nil else {
            return true
        }
        
        elementToScore!.score = elementToScore!.score + upscore
        elementToScore!.scoreCounter = node.scoreCounter + 1
        
        if let parent = elementToScore!.parent {
            parent.score = parent.score + upscore
            parent.scoreCounter = parent.scoreCounter + 1
        }
        
        if let parentParent = elementToScore!.parent?.parent {
            parentParent.score = parentParent.score + (upscore / 2)
            parentParent.scoreCounter = parentParent.scoreCounter + 0.5
        }
        
        return true
        
    }
    
}
