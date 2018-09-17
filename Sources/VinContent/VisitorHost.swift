//  Copyright © 2017 Vincode. All rights reserved.

public protocol VisitorHost {
    func host(visitor: Visitor) throws
}
