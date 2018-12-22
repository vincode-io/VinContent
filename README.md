[![CocoaPods](https://img.shields.io/cocoapods/p/VinContent.svg?maxAge=3601)](#)
[![Swift](https://img.shields.io/badge/Swift-4.0-F16D39.svg?style=flat)](#)

# VinContent

### HTML Main content extractor for Swift

Main content extraction is the process of extracting relavant text from an HTML page.  Relavant text is the
text that a typical person is interested in reading.  In most cases this is an article.  What isn't relavant,
advertisements and other junk, is discarded.

A common usage of main content extraction is Safari's Reader functionality.  Other implementations of this are
[Goose](https://github.com/GravityLabs/goose), [Dragnet](https://github.com/dragnet-org/dragnet), [Newspaper](https://github.com/codelucas/newspaper), and many more.

Usage
-----

VinContent has a small API implemented using the delegate pattern.  

Example usage:

```Swift
import VinContent

class WebBrowser: ContentExtractorDelegate {
    
    var contentExtractor: ContentExtractor?
    
    func yourMainProcess() {
         
         // You can supply either a URL, HTML as a String or both.
         // The more information you give VinContent, the better it will do.
         // If HTML is supplied, a VinContent will not do a network request to
         // get the information.  If the URL is supplied, but not the HTML
         // VinContent will retrieve the page for you.
         
         contentExtractor = ContentExtractor(url: yourURL, html: yourHTML)
         
         // This class implements the ContentExtractorDelegate methods
         contentExtractor.delegate = self
         
         // Initiate the process.  It will run in the background without doing
         // anything on your part.  The delegate methods will be called on the
         // main thread.
         contentExtractor.process()
         
    }
    
    // This is the first delegate method to implement.  It will be called if there
    // are any problems while processing the HTML document.
    func contentExtractionDidFail(with error: Error) {
       // Perform normal error handling here.
    }
    
    // This is the second delegate method.  It will be called after the page
    // is downloaded (if necessary) and processed.
    func contentExtractionDidComplete(article: ExtractedArticle) {
       // Display the stripped down article here.
    }
    
}
```

Installation
------------

### CocoaPods

Just add the line below to your Podfile:

```ruby
pod 'VinContent'
```

Then run `pod install`

### Carthage

Coming soon...

### Swift Package Manager

Coming soon...

License
-------

MIT


