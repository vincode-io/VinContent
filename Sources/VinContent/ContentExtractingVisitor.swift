//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

class ContentExtractingVisitor: Visitor {

    static let extractExemptTags = ["html", "body", "head"]

    var clusters = [XMLElement]()
    
    func visit(host: VisitorHost) throws -> Bool {
        
        guard let node = host as? XMLElement else {
            return false
        }
     
        if ContentExtractingVisitor.extractExemptTags.contains(node.name!) {
            return true
        }
        
        if node.score >= ContentExtractor.scoreThreshold {
            clusters.append(node)
            return false
        }
        
        return true
        
    }
    
}
