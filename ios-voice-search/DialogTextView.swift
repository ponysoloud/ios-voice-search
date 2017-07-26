//
//  DialogTextView.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 14.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import UIKit

/*
 Custom UITextView for easy adding User and Machine phrases according
 to the attributed string styles
 */
class DialogTextView: UITextView {
    
    /*
     List of string attributes
     */
    private var customAttributes = TextAttributes()
    
    /* 
     Reset textView data with given text: NSMutableAttributedString, 
     that can be got from getMutableString() function
     */
    func reset(_ text: NSMutableAttributedString) {
        attributedText = text
    }
    
    /*
     Get current textView data as NSMutableAttributedString
     */
    func getMutableString() -> NSMutableAttributedString {
        return attributedText.mutableCopy() as! NSMutableAttributedString
    }
    
    /*
     Bleach all current textView data
     */
    func bleachPrevious() {
        let mutable = getMutableString()
        let color = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.4)
        mutable.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, mutable.length))
        
        attributedText = mutable
    }
    
    /*
     Add machine phrase to the textView
     */
    func addMachine(phrase: String) {
        var string = "\n"
            string.append(phrase)
            string.append("\n")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        customAttributes.paragraph = paragraphStyle
        
        let attrString = NSMutableAttributedString(string: string, attributes: customAttributes.attributes)
        
        let temp = NSMutableAttributedString()
            temp.append(attributedText)
            temp.append(attrString)
        
        attributedText = temp
        
        scrollToBottom()
    }
    
    
    /*
     Add user phrase to the textView
     */
    func addUser(phrase: String) {
        bleachPrevious()
        
        var string = "\n\""
            string.append(phrase)
            string.append("\"\n")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        customAttributes.paragraph = paragraphStyle
        
        let attrString = NSMutableAttributedString(string: string, attributes: customAttributes.attributes)
        
        let temp = NSMutableAttributedString()
            temp.append(attributedText)
            temp.append(attrString)
        
        attributedText = temp
        
        scrollToBottom()
    }
    
    
    /*
     Scroll view to bottom
     */
    func scrollToBottom() {
        let range = NSMakeRange(text.characters.count - 1, 0)
        scrollRangeToVisible(range)
    }
}

/*
 Class to contain and manage attributes array
 */
class TextAttributes {
    
    public var attributes: [String: Any] = [:]
    
    init() {
        font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        
        color = UIColor.white
        
        paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
    }
    
    
    var font: UIFont {
        get {
            return attributes[NSFontAttributeName] as! UIFont
        }
        
        set(value) {
            attributes[NSFontAttributeName] = value
        }
    }
    
    var color: UIColor {
        get {
            return attributes[NSForegroundColorAttributeName] as! UIColor
        }
        
        set(value) {
            attributes[NSForegroundColorAttributeName] = value
        }
    }
    
    var paragraph: NSMutableParagraphStyle {
        get {
            return attributes[NSParagraphStyleAttributeName] as! NSMutableParagraphStyle
        }
        
        set(value) {
            attributes[NSParagraphStyleAttributeName] = value
        }
    }
    
}
