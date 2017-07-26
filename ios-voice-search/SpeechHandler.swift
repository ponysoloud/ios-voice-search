//
//  SpeechHandler.swift
//  ios-voice-search
//
//  Created by Александр Пономарев on 16.07.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import Speech

enum SpeechHandlerAccessibilityStatus : Int {
    
    case inaccessible
    
    case waitingForStart
    
    case waitingForStop
    
}

enum AccessibilityError : Error {
    
    case InvalidTryToStartSpeech(String)
    
    case InvalidTryToStopSpeech(String)
}

/*
 User's speech handler class that manages audio control and speech recognizer components
 */
class SpeechHandler {
    
    /*
     Reference to delegate for checking changing of accessibility status
     */
    weak var delegate: SpeechHandlerDelegate?
    
    /*
     SpeechRecognizer user's device authorization status (Is .authorized?)
     */
    var isAuthorized: Bool = false { didSet { setAccessibilityStatus() } }
    
    /*
     SpeechRecognizer availability property accessor (equal to the speechRecognizer.isAvailable - use to check the changing and call setAccessibilityStatus)
     */
    var isAvailable: Bool = false { didSet { setAccessibilityStatus() } }
    
    /*
     Accesibility status of speech handler
     */
    var accessibilityStatus: SpeechHandlerAccessibilityStatus = .inaccessible {
        
        didSet(oldValue) {
            if oldValue != accessibilityStatus {
                delegate?.speechHandler(self, accessibilityStatusDidChangeTo: accessibilityStatus)
            }
        }
    }
    
    let speechRecognizer: SFSpeechRecognizer!
    
    private let audioEngine = AVAudioEngine()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /*
     Audio running indicator
     */
    private var _speechAudioInProcess: Bool = false { didSet { setAccessibilityStatus() } }
    
    /*
     Recognition process running indicator
     */
    private var _speechRecognitionInProcess: Bool = false { didSet { setAccessibilityStatus() } }
    
    
    convenience init?() {
        self.init(locale: Locale.current)
    }
    
    init?(locale: Locale) {
        if !SFSpeechRecognizer.supportedLocales().contains(locale) {
            return nil
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        isAvailable = speechRecognizer.isAvailable
        setAccessibilityStatus()
    }
    
    
    /*
     Start recording speech
     */
    func recordSpeech(_ handler: @escaping (_ isFinal: Bool, _ result: String?) -> Swift.Void) throws {
        
        if accessibilityStatus != .waitingForStart {
            throw AccessibilityError.InvalidTryToStartSpeech("")
        }
        
        _speechRecognitionInProcess = true
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        var recorderedSpeech: String?
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                recorderedSpeech = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self._speechRecognitionInProcess = false
            }
            
            handler(isFinal, recorderedSpeech)
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        _speechAudioInProcess = true
    }
    
    /*
     Stop recording speech
     */
    func stopSpeech() throws {
        if accessibilityStatus != .waitingForStop {
            throw AccessibilityError.InvalidTryToStopSpeech("")
        }
        
        _speechAudioInProcess = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
    }
    
    /*
     Update accessibility status according to special variables that define different parts of access
     */
    private func setAccessibilityStatus() {
        if _speechAudioInProcess != _speechRecognitionInProcess || !isAuthorized || !isAvailable {
            accessibilityStatus = .inaccessible
            return
        }
        
        if (_speechAudioInProcess) {
            accessibilityStatus = .waitingForStop
            return
        }
        
        accessibilityStatus = .waitingForStart
    }
}


/*
 Delegate to check changing of accessibility status
 */
protocol SpeechHandlerDelegate : NSObjectProtocol {
    
    // Called when the accessibility status of the given handler changes
    func speechHandler(_ speechHandler: SpeechHandler, accessibilityStatusDidChangeTo accessibility: SpeechHandlerAccessibilityStatus)
}


