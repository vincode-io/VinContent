//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

class ContentPostScrubbingVisitor: Visitor {
    
    func visit(host: VisitorHost) throws -> Bool {
        
        guard let element = host as? XMLElement else {
            return false
        }
        
        // Only remove block elements
        if !element.blockElement {
            return true
        }
        
        // These are typically ads.
        if try element.hasHighLinkDensity() {
            try remove(element)
            return false
        }
        
        guard let parentElement = element.parent as? XMLElement else {
            assertionFailure("There should always be a parent element here.")
            return true
        }
        
        let avgSiblingScore = Double(parentElement.score) / (parentElement.scoreCounter)
        let scoreThreshold = avgSiblingScore * 0.1
        
        if Double(element.score) < scoreThreshold {
            try remove(element)
            return false
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
