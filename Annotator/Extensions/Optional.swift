//
//  Optional.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import Foundation

extension Optional {
    enum Error: Swift.Error {
        case instanceIsNil
    }
    
    func get() throws -> Wrapped {
        guard let value = self else {
            throw Error.instanceIsNil
        }
        return value
    }
}
