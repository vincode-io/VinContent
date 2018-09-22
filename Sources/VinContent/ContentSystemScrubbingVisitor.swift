//  Copyright © 2018 Vincode. All rights reserved.

import Foundation
import VinXML

class ContentSystemScrubbingVisitor: XMLVisitor {
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let element = host as? XMLElement else {
            return false
        }
        
        // Clean up the scoring attributes now that we don't need them any more
        element.removeAttribute(forName: ContentExtractor.scoreAttrName)
        element.removeAttribute(forName: ContentExtractor.scoreCounterAttrName)
        
        return true
        
    }
    
}
