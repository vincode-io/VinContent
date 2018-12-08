//
//  Created by Maurice Parker on 2/16/17.
//  Copyright © 2017 Vincode. All rights reserved.
//

public enum XMLNodeType: Int {
    case ElementNode = 1
    case AttributeNode = 2
    case TextNode = 3
    case CDATASectionNode = 4
    case EntityRefNode = 5
    case EntityNode = 6
    case PINode = 7
    case CommentNode = 8
    case DocumentNode = 9
    case DocumentTypeNode = 10
    case DocumentFragmentNode = 11
    case NotationNode = 12
    case HTMLDocumentNode = 13
    case DTDNode = 14
    case ElementDecl = 15
    case AttributeDecl = 16
    case EntityDecl = 17
    case NamespaceDecl = 18
    case XIncludeStart = 19
    case XIncludeEnd = 20
    case DOCBDocumentNode = 21
}
