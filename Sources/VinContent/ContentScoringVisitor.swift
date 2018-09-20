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
            upscore = upscore + 3
        }

        // Boost images since they will never have stop words and we want to pick them
        // up if they are part of a cluster.
        if elementName == "img" {
            upscore = upscore + 3
        }
        
        // Bump the score based on the number of conversational words found
        if let elementText = node.text {
            let contentStopWords = StopWords.countStopWords(elementText)
            upscore = upscore + contentStopWords
        }
        
//        print("node: \(node.name ?? "n/a") scored: \(upscore) on content: \(node.text ?? "n/a")")

        // This is to exclude comments since they tend to be at the bottom of the article
//        if (numberOfNodes > 15) {
//            if ((numberOfNodes - i) <= bottomNodesForNegativeScore) {
//                val booster: Float = bottomNodesForNegativeScore.toFloat - (numberOfNodes - i).toFloat
//                boostScore = -math.pow(booster.toDouble, 2.toDouble).toFloat
//                val negscore: Float = math.abs(boostScore) + negativeScoring
//                if (negscore > 40) {
//                    boostScore = 5
//                }
//            }
//        }

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
