//
//  NetworkClient.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import KeychainSwift

struct ApiResponse<T> {
    let success: Bool
    let code: String?
    let errorReason: String?
    let data: T
}

enum AsyncCallResult<T> {
    case success(data: T?, httpStatus: Int)
    case error(error: ApiError?)
}

enum HTTPVerb: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol NetworkClientObserver {
    func onNetworkClient(networkClient: NetworkClient, didReceiveUnauthorizedAccessFor request: URLRequest, onDoneRetryingRequest: @escaping (AsyncCallResult<Data>) -> Void)
}


class NetworkClient {
    static let kResponseError = "error"
    static let kResponseSuccess = "ok"
    static let kResponseStatus = "state"
    
    enum ParameterEncoding {
        case JSON
        case URL
    }
    
    fileprivate(set) var observers = WeakObserverOrderedSet<NetworkClientObserver>()
    
    let endpointMapperClass: EndpointMapper.Type
    init(endpointMapperClass: EndpointMapper.Type) {
        self.endpointMapperClass = endpointMapperClass
    }
    
    // MARK: - HTTP Methods
    @discardableResult
    public func call(url: URL, verb: HTTPVerb, dict: [String: Any?]?, parameterEncoding: ParameterEncoding = .JSON, headers: [String: String]?, timeout: TimeInterval = 30, onDone: @escaping (AsyncCallResult<Data>) -> Void) -> URLSessionDataTask {
        var data: Data?
        var encodedURL: URL = url
        if parameterEncoding == .JSON, let dict = dict {
            data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        } else if parameterEncoding == .URL, let dict = dict {
            encodedURL = NetworkClient.url(with: encodedURL, urlParams: dict)
        }
        
        return call(url: encodedURL, verb: verb, data: data, headers: headers, timeout: timeout, onDone: onDone)
    }
    
    /// onDone is called on the main thread
    @discardableResult
    public func call(endpoint: ApiEndpoint, dict: [String: Any?]?, parameterEncoding: ParameterEncoding = .JSON, headers: [String: String]? = nil, timeout: TimeInterval = 30, onDone: @escaping (AsyncCallResult<Data>) -> Void) -> URLSessionDataTask {
        let string = "http://localhost:8080\(endpointMapperClass.path(for: endpoint))"
        let url = URL(string: string)!
        let method = endpointMapperClass.method(for: endpoint)
        return call(url: url, verb: method, dict: dict, parameterEncoding: parameterEncoding, headers: headers, timeout: timeout, onDone: onDone)
    }

    // swiftlint:disable:next function_parameter_count
    public func call(url: URL, verb: HTTPVerb, data: Data?, headers: [String: String]?, timeout: TimeInterval, onDone: @escaping (AsyncCallResult<Data>) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = verb.rawValue
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? Bundle.main.infoDictionary?[kCFBundleVersionKey as String]
        var allHeaders: [String: String] = ["content-type": "application/json",
                                            "app_version": "\(version ?? "")"]
        if let headers = headers {
            headers.forEach { allHeaders[$0] = $1 }
        }
        request.allHTTPHeaderFields = allHeaders
        request.httpBody = data
        request.timeoutInterval = timeout
        
        return call(request: request, onDone: onDone)
    }
    
    @discardableResult
    public func call(request: URLRequest, onDone: @escaping (AsyncCallResult<Data>) -> Void, refreshTokenOnUnauthorizedError: Bool = true) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil, let urlResponse = response as? HTTPURLResponse else {
                let error = ApiError.from(error: error)
                self?.dispatchToMainThread(asyncCallResult: .error(error: error), block: onDone)
                return
            }
            
            LOG(
                """
                [NetworkClient]
                \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? ""),
                headers: \(request.allHTTPHeaderFields?.description ?? "[]"),
                payload: \(try? request.httpBody?.mapJSON() ?? "[]")
                cUrl Request:
                \(request.curlString)
                -->
                Response \(urlResponse.statusCode) \(response?.description ?? "")
                Response Data \((try? data.mapJSON()) ?? "")
                Response JSON \(String(data: data, encoding: .utf8) ?? "")
                
                """
            )
            guard let strongSelf = self else { return }
            if urlResponse.statusCode == 401 {
                self?.observers.invoke {
                $0.onNetworkClient(networkClient: strongSelf, didReceiveUnauthorizedAccessFor: request, onDoneRetryingRequest: onDone)
                }
            } else {
                self?.dispatchToMainThread(asyncCallResult: .success(data: data, httpStatus: urlResponse.statusCode), block: onDone)
            }
        }
        task.resume()
        return task
    }
    
    // MARK: - Thread Helper
    private func dispatchToMainThread<T>(asyncCallResult: AsyncCallResult<T>, block: @escaping (AsyncCallResult<T>) -> Void) {
        if Thread.current == Thread.main {
            block(asyncCallResult)
        } else {
            DispatchQueue.main.async {
                block(asyncCallResult)
            }
        }
    }
    
    // MARK: - Parsing Helpers
    static func url(with url: URL, urlParams dict: [String: Any?]) -> URL {
        var urlComponents = URLComponents(string: url.absoluteString)
        
        let queryItems = dict.flatMap({ (key, value) -> [URLQueryItem] in
            if let value = value as? String {
                return [ URLQueryItem(name: key, value: value) ]
            } else if let value = value as? [String] {
                return value.compactMap({ string -> URLQueryItem? in
                    return URLQueryItem(name: "\(key)[]", value: string)
                })
            }
            
            return []
        })
        
        urlComponents?.queryItems = queryItems
        
        return urlComponents?.url ?? url
    }
    
    static func parseApiDictResponse(from data: Data?) throws -> ApiResponse<[String: Any]> {
        do {
            let jsonResponse = try data?.mapJSON()
            if  let jsonResponse = jsonResponse as? [String: Any],
                let state = jsonResponse[NetworkClient.kResponseStatus] as? String {
                return ApiResponse(
                    success: state == kResponseSuccess,
                    code: jsonResponse["code"] as? String,
                    errorReason: jsonResponse["reason"] as? String,
                    data: jsonResponse
                )
            } else {
                throw ApiError.unexpectedApiResponse
            }
        } catch let error {
            throw ApiError.other(error: error)
        }
    }
    
    static func parseApiListResponse(from data: Data?) throws -> ApiResponse<[[String: Any]]> {
        do {
            let jsonResponse = try data?.mapJSON()
            if  let jsonResponse = jsonResponse as? [[String: Any]] {
                return ApiResponse(
                    success: true,
                    code: nil,
                    errorReason: nil,
                    data: jsonResponse
                )
            } else {
                throw ApiError.unexpectedApiResponse
            }
        } catch let error {
            throw ApiError.other(error: error)
        }
    }
    
    static func data<T: Decodable>(from array: [[String: Any]]) throws -> [T]? {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(
            withJSONObject: array,
            options: []
        )
        return try decoder.decode([T].self, from: data)
    }
    
    // MARK: - Observer
    public func register(observer: NetworkClientObserver) {
        assert(Thread.isMainThread, "[NetworkClient] register observer from background thread")
        observers.add(value: observer)
    }
    public func unregister(observer: NetworkClientObserver) {
        assert(Thread.isMainThread, "[NetworkClient] unregister observer from background thread")
        observers.remove(value: observer)
    }
    
}

extension NetworkClient: EngineComponent {
    func onLogoutUser() {
    }
    
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
    }
}
