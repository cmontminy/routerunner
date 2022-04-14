//
//  TTS.swift
//  Route Runner
//
//  Created by Colette Montminy on 4/13/22.
//

import Foundation
import AVFoundation

class TTS {
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    func speak(utterance:String) -> Void {
        // only speak if setting is enabled
        if UserDefaults.standard.bool(forKey:"RouteRunnerTTSModeOn") {
            myUtterance = AVSpeechUtterance(string: utterance)
            myUtterance.rate = 0.5
            // adds utterance to the AVSpeech queue,
            // so no need to worry about getting cut off
            synth.speak(myUtterance)
        } else {
            print("TTS mode is off !")
        }
    }
    
    func isSpeaking() -> Bool {
        return synth.isSpeaking
    }
}
