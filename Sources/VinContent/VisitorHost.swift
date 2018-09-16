//
//  VisitorHost.swift
//  VinXML
//
//  Created by Maurice Parker on 2/14/17.
//  Copyright © 2017 Vincode. All rights reserved.
//
public protocol VisitorHost {
    func host(visitor: Visitor) throws
}
