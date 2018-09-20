//  Copyright © 2017 Vincode. All rights reserved.

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension String {
    
    func trimmed() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        return trimmed
    }
    
}
