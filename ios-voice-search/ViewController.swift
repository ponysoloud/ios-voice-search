//
//  ViewController.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 13.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import Speech
import UIKit

class ViewController: UIViewController, SFSpeechRecognizerDelegate, SpeechHandlerDelegate {
    
    @IBOutlet weak var spokenTextView: DialogTextView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    let speechHandler: SpeechHandler = SpeechHandler(locale: Locale(identifier: "ru-RU"))!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechHandler.delegate = self
        speechHandler.speechRecognizer.delegate = self
        
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
                self.speechHandler.isAuthorized = recordAvailabilityState
            }
            
            
        }
        
        self.spokenTextView.addMachine(phrase: "Здравствуйте. Нажмите на кнопку, чтобы начать поиск рейсов голосом")
    }
    
    
    /*
     "Record" button tap
     */
    @IBAction func recordTapped(_ sender: Any) {
        print("touch")
        if speechHandler.accessibilityStatus == .waitingForStop {
            // Stopping speech
            do {
                try speechHandler.stopSpeech()
                recordButton.setTitle("Speak", for: .normal)
            } catch {
                self.spokenTextView.addMachine(phrase: "Не получилось остановить запись речи")
            }
            
        } else {
            // Starting speech
            do {
                recordButton.setTitle("Stop", for: .normal)
                
                // Save textView data before getting user's speech for correcting writing it word to word (user says word - it's printed)
                let savedState = self.spokenTextView.getMutableString()
                try speechHandler.recordSpeech { isFinal, result in
                    
                    self.spokenTextView.reset(savedState)
                    self.spokenTextView.addUser(phrase: result ?? "Что-то непонятное")
                    
                    // Handle last user's speech iteration - final phrase
                    if isFinal {
                        DataManager.getResult(withInput: result!) { result in
                            if let result = result {
                                
                                if let message = result.message {
                                    self.spokenTextView.addMachine(phrase: message)
                                }
                                
                                // Handle parameters: printing, sending...
                                if let params = result.parameters {
                                    // Printing
                                    let output = params.output()
                                    for (name, value) in output {
                                        self.spokenTextView.addMachine(phrase: "\(name) \(value)")
                                    }
                                    
                                }
                            } else {
                                self.spokenTextView.addMachine(phrase: "Извините, кажется что-то пошло не так")
                            }
                        }// getResult
                    }
                }
            } catch {
                self.spokenTextView.addMachine(phrase: "Кажется возникла проблема с записью речи")
            }
            
        }
    }
    
    /*
     SpeechHandlerDelegate function that called when the accessibility status of the given handler changes
     */
    func speechHandler(_ speechHandler: SpeechHandler, accessibilityStatusDidChangeTo accessibility: SpeechHandlerAccessibilityStatus) {
        if accessibility == SpeechHandlerAccessibilityStatus.inaccessible {
            recordButton.isEnabled = false
        } else {
            recordButton.isEnabled = true
        }
    }
    
    /*
     SFSpeechRecognizerDelegate function that called when the availability of the given speechRecognizer changes
     */
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Is available \(available)")
        self.speechHandler.isAvailable = available
    }
    
}
