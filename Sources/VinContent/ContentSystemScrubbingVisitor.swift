//  Copyright © 2018 Vincode. All rights reserved.

import Foundation

class ContentSystemScrubbingVisitor: Visitor {
    
    func visit(host: VisitorHost) throws -> Bool {
        
        guard let element = host as? XMLElement else {
            return false
        }
        
        // Clean up the scoring attributes now that we don't need them any more
        element.removeAttribute(forName: ContentExtractor.scoreAttrName)
        element.removeAttribute(forName: ContentExtractor.scoreCounterAttrName)
        
        return true
        
    }
    
}
