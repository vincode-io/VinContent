//  Copyright © 2017 Vincode. All rights reserved.

public protocol Visitor {
    func visit(host: VisitorHost) throws -> Bool
}
