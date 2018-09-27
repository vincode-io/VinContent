//
//  ContentPostScrubbingVisitor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 3/28/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import VinXML

class ContentPostScrubbingVisitor: XMLVisitor {
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
     
        // Only remove block elements
        if !node.blockElement {
            return true
        }

        let avgSiblingScore = Double(node.parent?.score ?? 0) / (node.parent?.scoreCounter ?? 1)
        let scoreThreshold = avgSiblingScore * 0.5
        
        if Double(node.score) < scoreThreshold {
            try remove(node)
            return false
        }
    
        return true
        
    }
    
    private func remove(_ node: VinXML.XMLNode) throws {
//        if let classValue = node.attributes["class"] {
//            print("--- postscrubber \(node.name ?? "n/a") *** \(classValue)")
//        } else {
//            print("--- postscrubber \(node.name ?? "n/a")")
//        }
        try node.remove()
    }

}
