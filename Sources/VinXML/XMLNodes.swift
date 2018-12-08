//
//  Created by Maurice Parker on 3/4/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

public class XMLNodes: Sequence {
    
    var root: XMLNode?

    public init(root: XMLNode?) {
        self.root = root
    }
    
    public init(doc: XMLDocument?, parent: XMLNode?) {
        guard let firstChildNodePtr = parent?.nodePtr.pointee.children else { return }
        self.root = XMLNode(doc: doc, parent: parent, nodePtr: firstChildNodePtr)
    }
    
    public var isEmpty: Bool {
        return root == nil
    }
    
    public var first: XMLNode? {
        return root
    }
    
    public func index(of findElement: XMLNode) -> Int? {
        for (i, node) in self.enumerated() {
            if findElement == node {
                return i
            }
        }
        return nil
    }
    
    public subscript(index: Int) -> XMLNode? {
        for (i, node) in self.enumerated() {
            if i == index {
                return node
            }
        }
        return nil
    }
    
    public func makeIterator() -> AnyIterator<XMLNode> {
        
        var iteratorCurrent = root

        return AnyIterator {
            
            guard iteratorCurrent != nil else { return nil }
            
            let temp = iteratorCurrent!
            iteratorCurrent = temp.nextSibling()
            return temp
            
        }
        
    }
    
}
