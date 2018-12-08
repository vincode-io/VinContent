//
//  Created by Maurice Parker on 3/4/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

import vinlibxml2

extension String {
    
    var xmlChars: [xmlChar] {
        get {
            return utf8CString.map { xmlChar($0) }
        }
    }
    
    func trimmed() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        return trimmed
    }
    
}
