//
//  ContentExtractor.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/4/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import Foundation

public enum ContentExtractorState {
    case ready
    case unableToParse
    case processing
    case failedToParse
    case complete
}

public protocol ContentExtractorDelegate {
    func contentExtractionDidFail(with: Error)
    func contentExtractionDidComplete(article: ExtractedArticle)
}

public enum ContentExtractorError: Error {
    case UnableToParseHTML
    case MissingURL
    case UnableToLoadURL
}

public class ContentExtractor {
    
    static let scoreAttrName = "score.vincode.io"
    static let scoreCounterAttrName = "scoreCounter.vincode.io"
    static let scoreThreshold = 20
    
    private lazy var incompatibleHosts: [String] = {
        let bundle = Bundle(for: ContentExtractor.self)
        let url = bundle.url(forResource: "incompatible_hosts", withExtension: "txt")
        if let words = try? String(contentsOf: url!) {
            return words.components(separatedBy: .whitespacesAndNewlines).map( { $0.lowercased() } )
        }
        return [String]()
    }()
    
    
    public var state: ContentExtractorState!
    public var article: ExtractedArticle?
    public var delegate: ContentExtractorDelegate?
    
    private var url: URL!
    private var html: String!
    
    public init(_ url: URL) {
        self.url = url
        state = compatibleURL(url) ? .ready : .unableToParse
    }
    
    public init(_ html: String) {
        self.html = html
        state = .ready
    }
    
    public func process() {
        
        state = .processing

        if url != nil {
            processURL()
        } else {
            processHTML()
        }
        
    }
    
    private func processURL() {
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.state = .failedToParse
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidFail(with: error)
                }
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                strongSelf.state = .failedToParse
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidFail(with: ContentExtractorError.UnableToLoadURL)
                }
                return
            }
            
            do {
                let article = try strongSelf.extractArticle(from: html, source: strongSelf.url)
                strongSelf.state = .complete
                strongSelf.article = article
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidComplete(article: article)
                }
            } catch {
                strongSelf.state = .failedToParse
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidFail(with: error)
                }
            }
            
        }
        
        dataTask.resume()
    }
    
    private func processHTML() {
        
        DispatchQueue.global().async { [weak self] in

            guard let strongSelf = self else { return }
            
            do {
                let article = try strongSelf.extractArticle(from: strongSelf.html)
                strongSelf.state = .complete
                strongSelf.article = article
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidComplete(article: article)
                }
            } catch {
                strongSelf.state = .failedToParse
                DispatchQueue.main.async {
                    strongSelf.delegate?.contentExtractionDidFail(with: error)
                }
            }
            
        }
        
    }
    
    private func compatibleURL(_ url: URL) -> Bool {

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host else {
            return false
        }

        for badHost in incompatibleHosts {
            if host.contains(badHost) {
                return false
            }
        }
        
        return true
        
    }
    
    private func extractArticle(from htmlString: String, source: URL? = nil) throws -> ExtractedArticle {
        
        var article = ExtractedArticle()
        
        guard let doc = try VinContent.XMLDocument(html: htmlString) else {
            throw ContentExtractorError.UnableToParseHTML
        }
        
        article.title = try extractTitle(doc: doc)
        article.byline = try extractByline(doc: doc)
        article.publisher = try extractPublisher(doc: doc, source: source)
        article.description = try extractDescription(doc: doc)
        article.source = try extractSource(doc: doc, source: source)
        article.sourceHTML = htmlString
        article.publishDate = try extractPublishDate(doc: doc)
        article.image = try extractImage(doc: doc)
        
        try doc.root?.host(visitor: ContentPreScrubbingVisitor(articleTitle: article.title))
        let contentScoringVisitor = ContentScoringVisitor()
        try doc.root?.host(visitor: contentScoringVisitor)

        let contentExtractingVisitor = ContentExtractingVisitor()
        try doc.root?.host(visitor: contentExtractingVisitor)
        
        let clusters = contentExtractingVisitor.clusters
        
        if contentExtractingVisitor.clusters.count == 0 {
            throw ContentExtractorError.UnableToParseHTML
        }

        let postScrubber = ContentPostScrubbingVisitor()
        for cluster in clusters {
            try cluster.host(visitor: postScrubber)
        }
        
        let contentSystemScrubbingVisitor = ContentSystemScrubbingVisitor()
        try doc.root?.host(visitor: contentSystemScrubbingVisitor)
        
        article.mangledDocument = doc
        article.content = clusters
    
        return article
        
    }
    
    private func extractTitle(doc: VinContent.XMLDocument) throws -> String? {
        
        var title: String?
        
        let titlePath = "//*/meta[@property='og:title' or @name='og:title' or @property='twitter:title' or @name='twitter:title']"
        if let node = try doc.queryFirst(xpath: titlePath) {
            title = node.attributes["content"]
        }
        
        if title == nil {
            if let node = try doc.queryFirst(xpath: "//*/title") {
                title = node.text
            }
        }
        
        guard let unparsedTitle = title else {
            return nil
        }
        
        // Fix these messed up compound titles that web designers like to use.
        // TODO: change this to a loop and use this list from Goose:
        // """ | """, " • ", " › ", " :: ", " » ", " - ", " : ", " — ", " · "
        if let range = unparsedTitle.range(of: " |") {
            return String(unparsedTitle[..<range.lowerBound])
        }
        if let range = unparsedTitle.range(of: " »") {
            return String(unparsedTitle[..<range.lowerBound])
        }
        if let range = unparsedTitle.range(of: " :") {
            return String(unparsedTitle[..<range.lowerBound])
        }
        if let range = unparsedTitle.range(of: " -") {
            return String(unparsedTitle[..<range.lowerBound])
        }
        if let range = unparsedTitle.range(of: " •") {
            return String(unparsedTitle[..<range.lowerBound])
        }
    
        return unparsedTitle.trimmed()
        
    }
    
    private func extractByline(doc: VinContent.XMLDocument) throws -> String? {
        
        if let author = try doc.metaTagContent(forName: "author") {
            return author
        }
        
        if let author = try doc.metaTagContent(forName: "article:author") {
            return author
        }
        
        // I don't think rel is supposed to be used much anymore.
        var nodes = try doc.query(xpath: "//*[@rel='author']")
        for node in nodes {
            if let nodeContent = node.text {
                // TODO: where you going to do something here Mo?
                let cleanedContent = nodeContent
                if validByLine(candidate: cleanedContent) {
                    return cleanedContent
                }
            }
        }
        
        // This pulls in the schema.org author definition
        nodes = try doc.query(xpath: "//*[@itemprop='author']/*[@itemprop='name']")
        for node in nodes {
            if let nodeContent = node.text {
                let cleanedContent = nodeContent
                if validByLine(candidate: cleanedContent) {
                    return cleanedContent
                }
            }
        }
        
        // This is a this is a final attempt to do something crazy and get the author.  Believe it or not, it actually works.
        let classPath = "//*[contains(translate(@class, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'author') or contains(translate(@class, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'),'byline')]"
        if let node = try doc.queryFirst(xpath: classPath) {
            if let title = node.text {
                return title.trimmed()
            }
        }

        return nil
        
    }
    
    private func validByLine(candidate: String?) -> Bool {
        guard let candidate = candidate else {
            return false
        }
        return candidate.count > 0 && candidate.count < 100
    }
    
    private func extractPublisher(doc: VinContent.XMLDocument, source: URL?) throws -> String? {
        
        if let publisher = try doc.metaTagContent(forName: "og:site_name") {
            return publisher
        }
        
        if let publisher = try doc.metaTagContent(forName: "twitter:site") {
            return publisher
        }
        
        if let publisher = try doc.metaTagContent(forName: "article:publisher") {
            return publisher
        }
        
        return source?.host
        
    }
    
    private func extractDescription(doc: VinContent.XMLDocument) throws -> String? {

        if let description = try doc.metaTagContent(forName: "description") {
            return description
        }
        
        if let description = try doc.metaTagContent(forName: "og:description") {
            return description
        }
        
        return nil
        
    }
    
    private func extractSource(doc: VinContent.XMLDocument, source: URL?) throws -> URL? {
        
        if let ogURL = try doc.metaTagContent(forName: "og:url") {
            if let result = URL(string: ogURL) {
                return result
            }
        }
        
        return source
        
    }
    
    private func extractPublishDate(doc: VinContent.XMLDocument) throws -> Date? {
        
        if let published = try doc.metaTagContent(forName: "article:published_time") {
            return try? Date(iso8601: published)
        }
        
        return nil
        
    }
    
    private func extractImage(doc: VinContent.XMLDocument) throws -> URL? {
        
        if let image = try doc.metaTagContent(forName: "og:image") {
            return URL(string: image)
        }
        
        if let image = try doc.metaTagContent(forName: "twitter:image:src") {
            return URL(string: image)
        }
        
        return nil
        
    }
    
}
