//
//  AFHTTPSessionManager+RACExtensions.swift
//  BoSS
//
//  Created by Emanuele Rudel on 28/02/15.
//  Copyright (c) 2015 Bureau of Street Services. All rights reserved.
//

import Foundation

extension AFHTTPSessionManager {
    
    internal func rac_GET(path: String, parameters: AnyObject? = nil) -> RACSignal {
        return rac_requestPath(path, paramters: parameters, withMethod: "GET")
    }
    
    internal func rac_POST(path: String, parameters: AnyObject? = nil) -> RACSignal {
        return rac_requestPath(path, paramters: parameters, withMethod: "POST")
    }
    
    internal func rac_POST(path: String, parameters: [NSObject: AnyObject] = [NSObject: AnyObject](), constructingBody closure: (AFMultipartFormData! -> Void)) -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            var result = RACDisposable {}
            
            if let strongSelf = self {
                let URLString = NSURL(string: path, relativeToURL: strongSelf.baseURL)!.absoluteString!
                let request = strongSelf.requestSerializer.multipartFormRequestWithMethod("POST", URLString: URLString, parameters: parameters, constructingBodyWithBlock: closure, error: nil)
                
                let task = strongSelf.dataTaskWithRequest(request, completionHandler: { (response, responseObject, error) in
                    if (error != nil) {
                        subscriber.sendError(error)
                    } else {
                        subscriber.sendNext(responseObject)
                        subscriber.sendCompleted()
                    }
                })
                task.resume()
                
                result = RACDisposable { _ in
                    task.cancel()
                }
            }
            
            return result
        }
    }
    
    // MARK: - Implementation
    
    private func rac_requestPath(path: String, paramters: AnyObject? = nil, withMethod method: String) -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            var result = RACDisposable {}
            
            if let strongSelf = self {
                let URLString = NSURL(string: path, relativeToURL: strongSelf.baseURL)!.absoluteString
                let request = strongSelf.requestSerializer .requestWithMethod(method, URLString: URLString, parameters: paramters, error: nil)
                
                let task = strongSelf.dataTaskWithRequest(request, completionHandler: { (response, responseObject, error) in
                    if (error != nil) {
                        subscriber.sendError(error)
                    } else {
                        subscriber.sendNext(responseObject)
                        subscriber.sendCompleted()
                    }
                })
                task.resume()
                
                result = RACDisposable { _ in
                    task.cancel
                }
            }
            
            return result
        }.replayLazily()
    }
    
}