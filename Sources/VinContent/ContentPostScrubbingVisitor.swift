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
    
    private var articleTitle: String?
    
    init(articleTitle: String?) {
        self.articleTitle = articleTitle
    }
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
     
        // Make sure that there aren't any wacky inline font size things
        node.attributes["style"] = nil
        
        // Only remove block elements
        if !node.blockElement {
            return true
        }

        // We are assuming that the title is being displayed by using the
        // extracted metadata.
        if node.name == "h1" && node.content == articleTitle {
            try remove(node)
            return false
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
            try remove(node)
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
//            print("--- postscrubber \(node.name ?? "n/a") *** \(classValue)")
//        } else {
//            print("--- postscrubber \(node.name ?? "n/a")")
//        }
        try node.remove()
    }

}
