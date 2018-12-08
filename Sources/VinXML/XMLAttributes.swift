//
//  Created by Maurice Parker on 2/25/17.
//  Copyright © 2017 Vincode. All rights reserved.
//
import vinlibxml2

public class XMLAttributes: Collection {

    unowned var parent: XMLNode

    init(parent: XMLNode) {
        self.parent = parent
    }

    public var startIndex: String {
      
        if let firstAttr = parent.nodePtr.pointee.properties {
            if let name = firstAttr.pointee.name {
                return String(cString: name)
            }
        }
        
        return String()
    }
    
    public var endIndex: String {

        var curAttr = parent.nodePtr.pointee.properties
        var lastAttr: xmlAttrPtr?
        while curAttr != nil {
            lastAttr = curAttr
            curAttr = curAttr!.pointee.next
        }
        
        if let name = lastAttr?.pointee.name {
            return String(cString: name)
        }
        
        return String()
        
    }
    
    public var names: [String] {
        
        var names = [String]()
        
        var curAttr = parent.nodePtr.pointee.properties
        while curAttr != nil {
            if let cString = curAttr?.pointee.name {
                names.append(String(cString: cString))
            }
            curAttr = curAttr!.pointee.next
        }
        
        return names
        
    }
    
    public var count: Int {
        var counter = 0
        var curAttr = parent.nodePtr.pointee.properties
        while curAttr != nil {
            counter = counter + 1
            curAttr = curAttr!.pointee.next
        }
        return counter
    }
    
    public func index(after i: String) -> String {
        
        if let currentAttrPtr = xmlHasProp(parent.nodePtr, i.xmlChars) {
            if let nextAttrPtr = currentAttrPtr.pointee.next {
                if let name = nextAttrPtr.pointee.name {
                    return String(cString: name)
                }
            }
        }
        
        return String()
        
    }
    
    public subscript(index: String) -> String? {

        get {
            let prop = xmlGetProp(parent.nodePtr, index.xmlChars)
            defer { xmlFree(prop) }
            if prop != nil {
                return String(cString: prop!)
            }
            return nil
        }
        
        set(newValue) {
            if newValue == nil {
                if let attrPtr = xmlHasProp(parent.nodePtr, index.xmlChars) {
                    xmlRemoveProp(attrPtr)
                }
            } else {
                xmlSetProp(parent.nodePtr, index.xmlChars, newValue!.xmlChars)
            }
        }
        
    }
    
}
