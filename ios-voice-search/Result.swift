//
//  Result.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 16.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import ApiAI

/*
 Wrapper class of AIResponseResult
 */
class Result {
    
    public var source: String = ""
    public var resolvedQuery: String = ""
    public var action: String = ""
    public var actionIncomplete: Bool!
    public var intentId: String = ""
    public var intentName: String = ""
    
    public var parameters: Parameters?
    public var message: String?
    
    init?(result: AIResponseResult) {
        
        guard let source = result.source else {
            return nil
        }
        
        guard let resolvedQuery = result.resolvedQuery else {
            return nil
        }
        
        guard let action = result.action else {
            return nil
        }
        
        guard let actionIncomplete = result.actionIncomplete else {
            return nil
        }
        
        guard let parameters = result.formattedParameters else {
            return nil
        }
        
        guard let intentId = result.metadata.indentId else {
            return nil
        }
        
        guard let intentName = result.metadata.intentName else {
            return nil
        }
        
        self.source = source
        self.resolvedQuery = resolvedQuery
        self.action = action
        self.actionIncomplete = actionIncomplete.boolValue
        self.intentId = intentId
        self.intentName = intentName
        
        switch action {
            
        case "find_flights.by_number":
            self.parameters = FindFlightsByNumberParameters(parameters)
            
        case "find_flights.between_points":
            self.parameters = FindFlightsBetweenPointsParameters(parameters)
            
        default:
            self.parameters = nil
            
        }
        
        self.message = result.formattedFulfillment
    }
}
