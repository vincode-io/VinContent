// Copyright © 2017 Vincode. All rights reserved.

import Foundation

extension Date {

    public init(_ day: Int, _ month: Int, _ year: Int) throws {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: gregorianCalendar, year: year, month: month, day: day)
        guard let date = gregorianCalendar.date(from: dateComponents) else {
            throw "Invalid date passed to initializer."
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }

    public init(iso8601: String) throws {
        if let isoDate = DateFormatter.iso8601.date(from: iso8601) {
            self.init(timeIntervalSince1970: isoDate.timeIntervalSince1970)
        } else {
            throw "Invalid ISO8601 date.  \(iso8601)"
        }
    }
    
}
