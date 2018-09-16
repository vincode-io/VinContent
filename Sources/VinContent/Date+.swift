// Copyright © 2017 Vincode. All rights reserved.

import Foundation

extension Date {

    public init(iso8601: String) throws {
        if let isoDate = DateFormatter.iso8601.date(from: iso8601) {
            self.init(timeIntervalSince1970: isoDate.timeIntervalSince1970)
        } else {
            throw "Invalid ISO8601 date.  \(iso8601)"
        }
    }
    
}
