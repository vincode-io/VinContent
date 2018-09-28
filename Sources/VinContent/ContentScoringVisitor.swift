//
//  ContentScoringVisitor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/16/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import VinXML

class ContentScoringVisitor: XMLVisitor {

    private static let embedTagNames: Set = ["object", "embed", "iframe"]
    private static let videoRegEx = try? NSRegularExpression(pattern: "//(www.)?(dailymotion|youtube|youtube-nocookie|player.vimeo).com", options: .caseInsensitive)
    private static let stopWords = StopWords()

    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }

        // TODO: Delete this.  It shouldn't be doing anything as high link density
        // stuff should have been removed by the prescrubber
//        // If this node is mostly links, don't score it
//        if try node.hasHighLinkDensity() {
//            return true
//        }

        guard let elementName = node.name else {
            return true
        }
        
        var upscore = 0
        
        // Boost headings since they aren't usually loaded with junk, but 
        // still sometimes don't have conversational words that would be picked up
        // with the stop words.
        if ["h1", "h2", "h3", "h4", "h5", "h6"].contains(elementName) {
            upscore = (ContentExtractor.scoreThreshold / 6)
        }

        // We are going to boost math elements assuming that advertisers won't abuse
        // this tag.  Since there are may not be words, let's max them.
        if elementName == "math" {
            upscore = ContentExtractor.scoreThreshold
        }
        
        // Boost images since they will never have stop words and we want to pick them
        // up if they are part of a cluster.
        if elementName == "img" {
            if let width = node.attributes["width"], let height = node.attributes["height"] {
                let pixelCount = (Int(width) ?? 0) * (Int(height) ?? 0)
                if pixelCount > 999999 {
                    upscore += ContentExtractor.scoreThreshold
                } else if pixelCount > 80000 {
                    upscore += (ContentExtractor.scoreThreshold / 2)
                }
            } else if node.attributes.contains("srcset") {
                upscore += (ContentExtractor.scoreThreshold / 2)
            } else {
                upscore += (ContentExtractor.scoreThreshold / 6)
            }
        }
        
        // Boost Video
        if ContentScoringVisitor.embedTagNames.contains(elementName) {
            if let attrContent = node.attributes["src"] {
                if ContentScoringVisitor.videoRegEx!.numberOfMatches(in: attrContent, options: [], range: NSMakeRange(0, attrContent.count)) > 0 {
                    upscore += (ContentExtractor.scoreThreshold / 2)
                }
            }
        }
        
        // Bump the score based on the number of conversational words found
        if let elementText = node.text {
            let contentStopWords = ContentScoringVisitor.stopWords.countStopWords(elementText)
            upscore = upscore + contentStopWords
        }

        var elementToScore: VinXML.XMLNode? = node
        while elementToScore != nil && !elementToScore!.blockElement {
            elementToScore = elementToScore!.parent
        }
        
        guard elementToScore != nil else {
            return true
        }
        
//        print("--- elementToScore ---\(node.name ?? "")->\(elementToScore!.name ?? "") upscore = \(upscore)" )
        
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
