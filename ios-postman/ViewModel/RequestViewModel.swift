//
//  RequestViewModel.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxSwift

enum HTTPMethods: String, Codable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case head = "HEAD"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
}

enum Auth: String, Codable, CaseIterable {
    case none  = "None"
    case basic = "Basic"
    case oauth1 = "OAuth 1.0a"
    case oauth2 = "OAuth 2.0"
}

func MainViewModel(
    inputRequest: Observable<Request>,
    networkProvider: Observable<NetworkProvider>,
    fileProvider: Observable<FileProvider>,
    responseParser: Observable<ResponseParser>,
    sendRequest: Observable<Void>,
    baseURL: Observable<String>,
    queryParams: Observable<[Parameter]>,
    headers: Observable<[Parameter]>,
    method: Observable<HTTPMethods>
) -> (Observable<Response>,
      Observable<Request>,
      Observable<Request>){
    
    let editedRequest = Observable
        .combineLatest(baseURL, queryParams, headers, method, inputRequest)
        .map { Request(baseURL: $0.0, queryParams: $0.1, headers: $0.2, method: $0.3, auth: .basic, identity: $0.4.identity) }
        
    let request = Observable.merge(
        editedRequest,
        inputRequest
    )
        
    // Skipping the request being imported in
    let saveRequest = request.skip(1)
    
    let networkResponse = sendRequest
        .withLatestFrom(request)
        .map { $0.asURL }
        .withLatestFrom(networkProvider) { ($1, $0) }
        .flatMapLatest { $0.performRequest($1) }
    
    let success = networkResponse.filterMap { $0.data.left }
    
    let error = networkResponse.filterMap { $0.data.right }
    
    let failedStatusCode = error
        .map { String($0.statusCodeError) }
        .replaceNilWith("No Status Code")
    
    let statusCode = Observable.merge(
        success.map { _ in "200" },
        failedStatusCode
    )
    
    let successBodyText = success
        .withLatestFrom(responseParser) { ($1, $0) }
        .map { $0.test($1) ?? NSAttributedString() }
    
    let errorFailedBodyText = error
        .map { $0.dataTaskError?.localizedDescription }
        .replaceNilWith("No Response")
        .map { NSAttributedString(string: "Encountered Error: \($0)") }
    
//    let bodyText = Observable.merge(
//        successBodyText,
//        errorFailedBodyText
//    )
    
    let time = networkResponse.map { String($0.time) }
    
    let response = Observable.zip(
        statusCode,
        successBodyText,
        time
    ).map { Response(statusCode: $0.0, body: $0.1, time: $0.2) }
    
    return (response, inputRequest, saveRequest)
}
