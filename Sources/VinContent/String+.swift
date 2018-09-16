//  Copyright © 2017 Vincode. All rights reserved.

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension String {
    
    func trimmed() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 1 {
            return nil
        }
        return trimmed
    }
    
}
