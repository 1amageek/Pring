//
//  OptionalProtocol.swift
//  Pring
//
//  Created by Shunpei Kobayashi on 2019/01/13.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

protocol OptionalProtocol {
    func wrappedType() -> Any.Type
}

extension Optional : OptionalProtocol {
    func wrappedType() -> Any.Type {
        return Wrapped.self
    }
}
