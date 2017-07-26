//
//  Parameters.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 13.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import ApiAI

/*
 Main Parameters class
 */
class Parameters {
    
    /*
     Are every parameter not nil
     */
    public var isCorrect: Bool = false
    
    init(_ parameters: [String: AIResponseParameter]) {}
    
    /*
     Strings array representation of Parameters class - [Param name as String: Param value as String]
     */
    public func output() -> [String: String] { return [String: String]() }
}

/*
 Finding flight by number parameters class
 */
class FindFlightsByNumberParameters: Parameters {
    
    public var airlines: String?
    
    public var number: Int?
    
    public var date: Date?
    
    override init(_ parameters: [String: AIResponseParameter]) {
        super.init(parameters)
        
        airlines = parameters["flight-company"]?.stringValue
        
        number = parameters["number"]?.numberValue.intValue
            
        date = parameters["date"]?.dateValue
        
        if airlines != nil && number != nil && date != nil {
            isCorrect = true
        }
    }
    
    override func output() -> [String: String] {
        var output: [String: String] = [:]
        
        if let airlines = airlines {
            output["@airlines:"] = airlines
        } else {
            output["@airlines:"] = "undefined"
        }
        
        if let number = number {
            output["@number:"] = String(number)
        } else {
            output["@number:"] = "undefined"
        }
        
        if let date = date {
            
            let dateFormatter : DateFormatter = {
                let df = DateFormatter()
                df.timeStyle = DateFormatter.Style.none
                df.dateStyle = DateFormatter.Style.short
                return df
            }()
            
            output["@date:"] = dateFormatter.string(from: date)
        } else {
            output["@date:"] = "undefined"
        }
        
        return output
    }
    
}

/*
 Finding flight between points parameters class
 */
class FindFlightsBetweenPointsParameters: Parameters {
    
    public var from: String?
    
    public var to: String?
    
    public var date: Date?
    
    override init(_ parameters: [String: AIResponseParameter]) {
        super.init(parameters)
        
        from = parameters["from-point"]?.stringValue
            
        to = parameters["to-point"]?.stringValue
            
        date = parameters["date"]?.dateValue
        
        if from != nil && to != nil && date != nil {
            isCorrect = true
        }
    }
    
    override func output() -> [String: String] {
        var output: [String: String] = [:]
        
        if let from = from {
            output["@from:"] = from
        } else {
            output["@from:"] = "undefined"
        }
        
        if let to = to {
            output["@to:"] = to
        } else {
            output["@to:"] = "undefined"
        }
        
        if let date = date {
            
            let dateFormatter : DateFormatter = {
                let df = DateFormatter()
                df.timeStyle = DateFormatter.Style.none
                df.dateStyle = DateFormatter.Style.short
                return df
            }()
            
            output["@date:"] = dateFormatter.string(from: date)
        } else {
            output["@date:"] = "undefined"
        }
        
        return output
    }
    
}
