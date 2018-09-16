//  Copyright © 2017 Vincode. All rights reserved.

class ContentScoringVisitor: Visitor {
    
    func visit(host: VisitorHost) throws -> Bool {
        
        guard let element = host as? XMLElement else {
            return false
        }
        
        // If this node is mostly links, don't score it
        if try element.hasHighLinkDensity() {
            return true
        }

        guard let elementName = element.name else {
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
        if let elementText = element.stringValue {
            let contentStopWords = StopWords.countStopWords(elementText)
            upscore = upscore + contentStopWords
        }
        
        var elementToScore: XMLElement? = element
        while elementToScore != nil && !elementToScore!.blockElement {
            elementToScore = elementToScore!.parent as? XMLElement
        }
        
        guard elementToScore != nil else {
            return true
        }
        
        elementToScore!.score = elementToScore!.score + upscore
        elementToScore!.scoreCounter = element.scoreCounter + 1
        
        if let parent = elementToScore!.parent as? XMLElement {
            parent.score = parent.score + upscore
            parent.scoreCounter = parent.scoreCounter + 1
        }
        
        if let parentParent = elementToScore!.parent?.parent as? XMLElement {
            parentParent.score = parentParent.score + (upscore / 2)
            parentParent.scoreCounter = parentParent.scoreCounter + 0.5
        }
        
        return true
        
    }
    
}
