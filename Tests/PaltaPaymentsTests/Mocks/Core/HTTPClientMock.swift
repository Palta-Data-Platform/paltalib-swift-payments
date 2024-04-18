//
//  HTTPClientMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaCore

final class HTTPClientMock: HTTPClient {
    var request: HTTPRequest?
    var result: Result<Any, Error>?
    
    var mandatoryHeaders: [String : String] = [:]

    func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    ) {
        self.request = request

        completion(
            result?
                .map { $0 as! SuccessResponse }
                .mapError { $0 as! NetworkErrorWithResponse<ErrorResponse> }
            ?? .failure(.noData)
        )
    }

    func perform<T: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<T, Error>) -> Void
    ) {
    }

    func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        requestMiddleware: @escaping (URLRequest) -> Void,
        responseMiddleware: @escaping (HTTPURLResponse?, Data?) -> Void,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    ) {
    }
}
