//
//  Endpoits.swift
//  arquitetura-mvvm
//
//  Created by Solutis on 05/01/18.
//  Copyright © 2018 Solutis. All rights reserved.
//

import Foundation

enum HTTPCodes: Int {
    
    case noCode = 0
    case ok = 200
    case created = 201
    case noContent = 204
    case notFound = 404
}

func ==(lhs: Int, rhs: HTTPCodes) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: String, rhs: HTTPCodes) -> Bool {
    return lhs == String(rhs.rawValue)
}

func !=(lhs: Int, rhs: HTTPCodes) -> Bool {
    return lhs != rhs.rawValue
}

func !=(lhs: String, rhs: HTTPCodes) -> Bool {
    return lhs != String(rhs.rawValue)
}

struct API {
    static let baseUrl = "https://jsonplaceholder.typicode.com"
}

protocol Endpoint {
    var path: String { get }
    var url: String { get }
}

enum Endpoints {
    
    enum Posts: Endpoint {
        case list
        
        public var path: String {
            switch self {
            case .list: return "/posts"
            }
        }
        
        public var url: String {
            switch self {
            case .list: return "\(API.baseUrl)\(path)"
            }
        }
    }
}
