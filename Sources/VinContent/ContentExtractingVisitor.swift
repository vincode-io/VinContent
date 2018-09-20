//
//  ContentExtractingVisitor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 3/28/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation
import VinXML

class ContentExtractingVisitor: XMLVisitor {

    static let extractExemptTags: Set = ["html", "body", "head"]

    var clusters: [VinXML.XMLNode] = []
    
    func visit(host: XMLVisitorHost) throws -> Bool {
        
        guard let node = host as? VinXML.XMLNode else {
            return false
        }
     
//        if let classValue = node.attributes["class"] {
//            print("--- extracting for --- \(node.name ?? "n/a") *** \(classValue) *** score: \(node.score)")
//        } else {
//            print("--- extracting for ---\(node.name ?? "n/a") *** score: \(node.score)")
//        }
        
        if let nodeName = node.name {
            if ContentExtractingVisitor.extractExemptTags.contains(nodeName) {
                return true
            }
        }
        
        if node.score >= ContentExtractor.scoreThreshold {
//            if let classValue = node.attributes["class"] {
//                print("--- extracting for --- \(node.name ?? "n/a") *** \(classValue) *** score: \(node.score)")
//            } else {
//                print("--- extracting for ---\(node.name ?? "n/a") *** score: \(node.score)")
//            }
            clusters.append(node)
            return false
        }
        
        return true
        
    }
    
}
