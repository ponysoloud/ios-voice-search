//
//  ViewController.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 05.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    static let region = "en-US"

    @IBOutlet weak var spokenTextView: UITextView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: region))!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            var recordAvailabilityState = false
            
            switch authStatus {
                
            case .authorized:
                recordAvailabilityState = true
                
            case .denied:
                recordAvailabilityState = false
                print("User denied access to speech recognition") //Log
                
            case .restricted:
                recordAvailabilityState = false
                print("Speech recognition restricted on this device") //Log
                
            case .notDetermined:
                recordAvailabilityState = false
                print("Speech recognition not yet authorized") //Log
            }
            
            
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = recordAvailabilityState
            }
            
        }
    }



    
    @IBAction func recordTapped(_ sender: Any) {
        
    }
}

