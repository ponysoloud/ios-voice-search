//
//  DataManager.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 16.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import ApiAI

/*
 Class for sending speech to parse and getting result of that
 */
class DataManager {
    
    /*
     Do request and get response
     */
    private static func requestWith(input text: String!, handler: @escaping (AIResponse?) -> Swift.Void) {
        let request = ApiAI.shared().textRequest()
        
        request?.query = [text]
        
        request?.setMappedCompletionBlockSuccess ({ (request, response) in
            let response = response as! AIResponse
            handler(response)
        }, failure: { (request, error) in
            handler(nil)
        })
        
        ApiAI.shared().enqueue(request)
    }
    
    /*
     Get action class object from response
     */
    static func getResult(withInput text: String!, handler: @escaping (Result?) -> Swift.Void) {
        
        requestWith(input: text) { response in
            if let airesult = response?.result {
                let r = Result(result: airesult)
                handler(r)
            } else {
                handler(nil)
            }
        }
    }
    
}

extension AIResponseResult {
    
    var formattedParameters: [String: AIResponseParameter]? {
        get {
            let params = parameters as? [String: AIResponseParameter]
            return params
        }
    }
    
    var formattedFulfillment: String? {
        get {
            return fulfillment.speech
        }
    }
    
}
