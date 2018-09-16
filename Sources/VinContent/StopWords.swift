// Copyright © 2017 Vincode. All rights reserved.

import Foundation

public class StopWords {
    
    private static var stopWords: [String] = {
        let bundle = Bundle(for: StopWords.self)
        let url = bundle.url(forResource: "stopwords", withExtension: "txt")
        if let words = try? String(contentsOf: url!) {
            return words.components(separatedBy: .whitespacesAndNewlines).map( { $0.lowercased() } )
        }
        return [String]()
    }()
    
    private static var punctuationRegEx = try? NSRegularExpression(pattern: "[^\\p{Ll}\\p{Lu}\\p{Lt}\\p{Lo}\\p{Nd}\\p{Pc}\\s]", options: [])
        
    public static func countStopWords(_ content: String) -> Int {
    
        guard !content.isEmpty else {
            return 0
        }
        
        let strippedInput = StopWords.removePunctuation(content)
        let candidateWords = strippedInput.components(separatedBy: .whitespacesAndNewlines).filter({ return !$0.isEmpty })
        var overlappingStopWords = [String]()

        candidateWords.forEach() { word in
            if StopWords.stopWords.contains(word.lowercased()) {
                overlappingStopWords.append(word)
            }
        }
        
        return overlappingStopWords.count
        
    }
    
    static func removePunctuation(_ content: String) -> String {
        let nsContent = NSString(string: content)
        let range = NSMakeRange(0, nsContent.length)
        let result = punctuationRegEx?.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
        return result ?? ""
    }
    
}
