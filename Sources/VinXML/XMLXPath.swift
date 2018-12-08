//
//  Created by Maurice Parker on 2/10/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import vinlibxml2

public protocol XMLXPath {
    func query(xpath: String) throws -> [XMLNode]
    func queryFirst(xpath: String) throws -> XMLNode?
    func remove(xpath: String) throws
}

extension XMLXPath {
    
    public func queryFirst(xpath: String) throws -> XMLNode? {
        let results = try self.query(xpath: xpath)
        guard results.count > 0 else {
            return nil
        }
        return results[0]
    }
    
    public func remove(xpath: String) throws {
        
        let results = try self.query(xpath: xpath)
        try results.forEach() { node in
            try node.remove()
        }
        
    }
    
}
