//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

public class ContentExtractor {
    
    static let scoreAttrName = "score.vincode.io"
    static let scoreCounterAttrName = "scoreCounter.vincode.io"
    static let scoreThreshold = 30

    public static func extractArticle(from htmlURL: URL) throws -> ContentArticle {
        let htmlContents = try String(contentsOf: htmlURL)
        return try ContentExtractor.extractArticle(from: htmlContents, source: htmlURL)
    }
    
    public static func extractArticle(from htmlString: String, source: URL) throws -> ContentArticle {
        
        let options = Int(XMLNode.Options.documentTidyHTML.rawValue)
        guard let doc = try? XMLDocument(xmlString: htmlString, options: options) else {
            throw ContentExtractorError.UnableToParseHTML
        }
        
        var article = ContentArticle()
        
        article.title = try extractTitle(doc: doc)
        article.byline = try extractByline(doc: doc)
        article.publisher = try extractPublisher(doc: doc, source: source)
        article.description = try extractDescription(doc: doc)
        article.source = try extractSource(doc: doc, source: source)
        article.publishDate = try extractPublishDate(doc: doc)
        article.image = try extractImage(doc: doc)
        
        guard let rootElement = doc.rootElement() else {
            throw ContentExtractorError.UnableToParseHTML
        }
        
        try rootElement.host(visitor: ContentPreScrubbingVisitor())
        try rootElement.host(visitor: ContentScoringVisitor())

        let contentExtractingVisitor = ContentExtractingVisitor()
        try rootElement.host(visitor: contentExtractingVisitor)
        
        let clusters = contentExtractingVisitor.clusters
        
        if contentExtractingVisitor.clusters.count == 0 {
            throw ContentExtractorError.UnableToParseHTML
        }

        let postScrubber = ContentPostScrubbingVisitor()
        for cluster in clusters {
            try cluster.host(visitor: postScrubber)
        }
        
        let systemScrubber = ContentSystemScrubbingVisitor()
        for cluster in clusters {
            try cluster.host(visitor: systemScrubber)
        }
        
        article.mangledDocument = doc
        article.content = clusters
        
        return article
        
    }
    
    private static func extractTitle(doc: XMLDocument) throws -> String? {
        
        var title: String?
        
        let titlePath = "//*/meta[@property='og:title' or @name='og:title' or @property='twitter:title' or @name='twitter:title']"
        if let node = try doc.firstNode(forXPath: titlePath) as? XMLElement {
            title = node.attribute(forName: "content")?.stringValue
        }
        
        if title == nil {
            if let node = try doc.firstNode(forXPath: "//*/title") {
                title = node.stringValue
            }
        }
        
        // Fix these messed up compound titles that web designers like to use.
        // TODO: change this to a loop and use this list:
        // """ | """, " • ", " › ", " :: ", " » ", " - ", " : ", " — ", " · "
        if let range = title?.range(of: " |") {
            title = title?.substring(to: range.lowerBound)
        }
        if let range = title?.range(of: " »") {
            title = title?.substring(to: range.lowerBound)
        }
        if let range = title?.range(of: " :") {
            title = title?.substring(to: range.lowerBound)
        }
        if let range = title?.range(of: " -") {
            title = title?.substring(to: range.lowerBound)
        }
        if let range = title?.range(of: " •") {
            title = title?.substring(to: range.lowerBound)
        }
    
        return title?.trimmed()
        
    }
    
    private static func extractByline(doc: XMLDocument) throws -> String? {
        
        if let author = try doc.metaTagContent(forName: "author") {
            return author
        }
        
        if let author = try doc.metaTagContent(forName: "article:author") {
            return author
        }
        
        // I don't think rel is supposed to be used much anymore.
        var nodes = try doc.nodes(forXPath: "//*[@rel='author']")
        for node in nodes {
            if let nodeContent = node.stringValue {
                // TODO: where you going to do something here Mo?
                let cleanedContent = nodeContent
                if validByLine(candidate: cleanedContent) {
                    return cleanedContent
                }
            }
        }
        
        // This pulls in the schema.org author definition
        nodes = try doc.nodes(forXPath: "//*[@itemprop='author']/*[@itemprop='name']")
        for node in nodes {
            if let nodeContent = node.stringValue {
                let cleanedContent = nodeContent
                if validByLine(candidate: cleanedContent) {
                    return cleanedContent
                }
            }
        }
        
        // This is a this is a final attempt to do something crazy and get the author.  Believe it or not, it actually works.
        let classPath = "//*[contains(translate(@class, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'author') or contains(translate(@class, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'byline')]"
        if let node = try doc.firstNode(forXPath: classPath) {
            if let title = node.stringValue {
                return title.trimmed()
            }
        }

        return nil
        
    }
    
    private static func validByLine(candidate: String?) -> Bool {
        guard let candidate = candidate else {
            return false
        }
        return candidate.count > 0 && candidate.count < 100
    }
    
    private static func extractPublisher(doc: XMLDocument, source: URL) throws -> String? {
        
        if let publisher = try doc.metaTagContent(forName: "og:site_name") {
            return publisher
        }
        
        if let publisher = try doc.metaTagContent(forName: "twitter:site") {
            return publisher
        }
        
        if let publisher = try doc.metaTagContent(forName: "article:publisher") {
            return publisher
        }
        
        return source.host
        
    }
    
    private static func extractDescription(doc: XMLDocument) throws -> String? {

        if let description = try doc.metaTagContent(forName: "description") {
            return description
        }
        
        if let description = try doc.metaTagContent(forName: "og:description") {
            return description
        }
        
        return nil
        
    }
    
    private static func extractSource(doc: XMLDocument, source: URL) throws -> URL? {
        
        if let ogURL = try doc.metaTagContent(forName: "og:url") {
            if let result = URL(string: ogURL) {
                return result
            }
        }
        
        return source
        
    }
    
    private static func extractPublishDate(doc: XMLDocument) throws -> Date? {
        
        if let published = try doc.metaTagContent(forName: "article:published_time") {
            return try? Date(iso8601: published)
        }
        
        return nil
        
    }
    
    private static func extractImage(doc: XMLDocument) throws -> URL? {
        
        if let image = try doc.metaTagContent(forName: "og:image") {
            return URL(string: image)
        }
        
        if let image = try doc.metaTagContent(forName: "twitter:image:src") {
            return URL(string: image)
        }
        
        return nil
        
    }
    
}
