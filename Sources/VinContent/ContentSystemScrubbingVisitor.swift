//  Copyright © 2018 Vincode. All rights reserved.

import Foundation
import VinXML

class ContentSystemScrubbingVisitor: XMLVisitor {
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
        
        // Clean up the scoring attributes now that we don't need them any more
        node.attributes[ContentExtractor.scoreAttrName] = nil
        node.attributes[ContentExtractor.scoreCounterAttrName] = nil
        
        return true
        
    }
    
}
