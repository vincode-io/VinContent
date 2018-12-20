Pod::Spec.new do |s|

  s.name         = "VinContent"
  s.version      = "1.0.3"
  s.summary      = "HTML main content extraction for Swift"
  s.description  = <<-DESC
VinContent is a main content extraction library for Swift.  Main content extraction is
the process of extracting relavant text from a HTML page.  Relavant text is
text that a typical person is interested in reading.  In most cases this is an article.  
What isn't relavant, advertisements and other junk, is discarded.
                   DESC
  s.homepage     = "https://github.com/vincode-io/VinContent"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "Maurice Parker" => "mo@vincode.io" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.swift_version = '4.0'
  s.source       = { :git => "https://github.com/vincode-io/VinContent.git", :tag => "#{s.version}" }
  s.source_files  = "Sources", "Sources/**/*.{swift,h,m}"
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/VinContent/Sources/VinXML' }
  s.preserve_paths = 'Sources/VinXML/module.modulemap'
  s.resource = 'Sources/VinContent/stopwords.txt'

end
