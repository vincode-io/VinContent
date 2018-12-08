//
//  Created by Maurice Parker on 1/30/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import vinlibxml2

public class XMLDocument: XMLXPath {
    
    var docPtr: xmlDocPtr!
    var pathCtxPtr: xmlXPathContextPtr!
    
    public var raw: String? {
        return root?.raw
    }
    
    public convenience init?(xml: String) throws {
        try self.init(data: xml, isXML: true)
    }
    
    public convenience init?(html: String) throws {
        try self.init(data: html, isXML: false)
    }
    
    public init?(data: String, isXML: Bool) throws {
    
        guard !data.isEmpty else { return nil }
        
        let bytes = data.cString(using: .utf8)
        let length = CInt(data.lengthOfBytes(using: .utf8))
        let encoding = CFStringGetCStringPtr(nil, CFStringBuiltInEncodings.UTF8.rawValue)

        let options: CInt = isXML ? 1 : (1 << 5 | 1 << 6)
        let function = isXML ? xmlReadMemory : htmlReadMemory
        
        docPtr = function(bytes, length, "", encoding, options)
        if docPtr == nil {
            return nil
        }

        pathCtxPtr = xmlXPathNewContext(docPtr)

    }
    
    public var root: XMLNode? {
        return XMLNode.init(doc: self, parent: nil, nodePtr: xmlDocGetRootElement(docPtr))
    }
    
    public func registerXPathNamespace(prefix: String, url: String) {
        xmlXPathRegisterNs(pathCtxPtr, prefix.xmlChars, url.xmlChars)
    }
    
    public func query(xpath: String) throws -> [XMLNode] {
        
        guard let xPathObj = xmlXPathEvalExpression(xpath.xmlChars, pathCtxPtr) else { return [] }
        defer { xmlXPathFreeObject(xPathObj) }
        
        guard let nodes = xPathObj.pointee.nodesetval else { return [] }
        
        let nodePtrs = UnsafeBufferPointer(start: nodes.pointee.nodeTab, count: Int(nodes.pointee.nodeNr))
        let xnodes = nodePtrs.compactMap { XMLNode.init(doc: self, parent: nil, nodePtr: $0) }
        
        return xnodes
        
    }
    
    public func replace(this: XMLNode, withThis: XMLNode) {
        xmlReplaceNode(this.nodePtr, withThis.nodePtr)
    }
    
    deinit {
        xmlFreeDoc(docPtr)
        xmlXPathFreeContext(pathCtxPtr)
    }
    
}
