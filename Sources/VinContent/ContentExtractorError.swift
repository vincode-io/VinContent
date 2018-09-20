//
//  ContentExtractorError.swift
//  VinFoundation
//
//  Created by Maurice Parker on 2/5/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

public enum ContentExtractorError: Error {
    case UnableToParseHTML
    case MissingURL
    case UnableToLoadURL
}
