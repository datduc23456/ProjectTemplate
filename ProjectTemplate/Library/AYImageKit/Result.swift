//
//  TrendingCollectionViewCell.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 17/11/2022.
//

import Foundation

public enum Result<Value> {
    
    case failure(Error)
    case success(Value)

    public var error: Error? {
        switch self {
        case .failure(let error): return error
        case .success: return nil
        }
    }

    public var value: Value? {
        switch self {
        case .failure: return nil
        case .success(let value): return value
        }
    }

    public func map<T>(_ transform: (Value) throws -> T) -> Result<T> {
        switch self {
        case .failure(let error): return .failure(error)
        case .success(let value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        }
    }
    
    public init(catching body: () throws -> Value) {
        do {
            let value = try body()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
    
}


