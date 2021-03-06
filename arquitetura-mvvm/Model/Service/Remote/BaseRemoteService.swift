//
//  BaseService.swift
//  arquitetura-mvvm
//
//  Created by Solutis on 05/01/18.
//  Copyright © 2018 Solutis. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class BaseRemoteService: BaseRemoteServiceProtocol {

    let encoding = JSONEncoding.default

    private static let sessionManager : SessionManager = {
        let serverTrustPolicies: [String:ServerTrustPolicy] = [
            API.baseUrl: ServerTrustPolicy.pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30
        let instance = SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))

        return instance
    }()

    func getSessionManager() -> SessionManager {
        return BaseRemoteService.sessionManager
    }
    
    func request<T>(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders? = nil) -> Observable<[T]> where T : Decodable {
        return Observable.create({ (observer) -> Disposable in
            self.getSessionManager().request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseJSON(completionHandler: {
                    if $0.result.isSuccess {
                        observer.on(.next(self.handlerResult(response: $0)))
                        observer.on(.completed)
                    } else {
                        observer.on(.error(self.validateResponse(response: $0)))
                    }
                })

            return Disposables.create()
        })
    }
    
    func request<T>(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders? = nil) -> Observable<T?> where T : Decodable {
        return Observable.create({ (observer) -> Disposable in
            self.getSessionManager().request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate()
                .responseJSON(completionHandler: {
                    if $0.result.isSuccess {
                        observer.on(.next(self.handlerResult(response: $0)))
                        observer.on(.completed)
                    } else {
                        observer.on(.error(self.validateResponse(response: $0)))
                    }
                })

            return Disposables.create()
        })
    }
    
    func handlerResult<T: Decodable>(response: DataResponse<Any>) -> [T] {
        if(response.response != nil && response.response!.statusCode == HTTPCodes.noContent) {
            return [T]()
        }
        
        guard let data = response.data else { return [T]() }
        
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            return [T]()
        }
    }
    
    func handlerResult<T: Decodable>(response: DataResponse<Any>) -> T? {
        if(response.response != nil && response.response!.statusCode == HTTPCodes.noContent) {
            return nil
        }
        
        guard let data = response.data else { return nil }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    func validateResponse(response: DataResponse<Any>) -> ResponseError {
        guard let data = response.data else { return ResponseError() }
        
        do {
            return try JSONDecoder().decode(ResponseError.self, from: data)
        } catch {
            return ResponseError()
        }
    }

}
