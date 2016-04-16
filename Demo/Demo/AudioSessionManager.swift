//
//  AudioSessionManager.swift
//  Demo
//
//  Created by little2s on 15/12/8.
//  Copyright © 2015年 Ninty. All rights reserved.
//

import Foundation
import AVFoundation

struct AudioSessionManager {
    static func setAudioSessionCategory(categoryConstant: String) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(categoryConstant)
            try audioSession.setActive(true)
        } catch {
            print("\(error)")
        }
    }
}
