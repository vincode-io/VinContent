//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

extension XMLNode {
    
    public func firstNode(forXPath xpath: String) throws -> XMLNode? {
        let results = try nodes(forXPath: xpath)
        if results.count > 0 {
            return results[0]
        }
        return nil
    }
    
}

extension XMLNode: VisitorHost {
    
    public func host(visitor: Visitor) throws {
        if try visitor.visit(host: self) {
            try children?.forEach() { node in
                try node.host(visitor: visitor)
            }
        }
    }
    
}
