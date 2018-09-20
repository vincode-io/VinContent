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

        // Convert article links to spans.  This makes it feel like you are reading
        // a book, since most articles these days are splattered with links.  Besides,
        // it feeds into the short attention span problem.  Links take people out of the
        // article they are reading before they have finished it.
        if node.name == "a" {
            node.attributes["href"] = nil
            node.name = "span"
        }
        
        // Make sure that there aren't any wacky inline font size things
        node.attributes["style"] = nil
        
        // Only remove block elements
        if !node.blockElement {
            return true
        }
        
        if try node.hasHighLinkDensity() {
            try remove(node)
            return false
        }
        
        let avgSiblingScore = Double(node.parent?.score ?? 0) / (node.parent?.scoreCounter ?? 1)
        let scoreThreshold = avgSiblingScore * 0.1
        
        if Double(node.score) < scoreThreshold {
//            #if DEBUG
//                print()
//                if let classValue = node.attributes["class"] {
//                    print("removing node: \(node.name ?? "") *** \(classValue), score: \(node.score), parentScore: \(node.parent?.score ?? 0) ")
//                } else {
//                    print("removing node: \(node.name ?? ""), score: \(node.score), parentScore: \(node.parent?.score ?? 0) ")
//                }
//                print("removing content: \(node.text ?? "")")
//            #endif
            try node.remove()
            return false
        } else {
//            #if DEBUG
//                print()
//                print("keeping node: \(node.name ?? ""), score: \(node.score), scoreThreshold: \(scoreThreshold), parentScore: \(node.parent?.score ?? 0) ")
//                print("keeping content: \(node.text ?? "")")
//            #endif
        }
    
        return true
        
    }
    
    private func remove(_ node: VinXML.XMLNode) throws {
//        if let classValue = node.attributes["class"] {
//            print("--- \(node.name ?? "n/a") *** \(classValue)")
//        } else {
//            print("--- \(node.name ?? "n/a")")
//        }
        try node.remove()
    }

}
