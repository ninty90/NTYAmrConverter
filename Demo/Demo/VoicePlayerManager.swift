//
//  AudioPlayerManager.swift
//  Demo
//
//  Created by little2s on 15/11/25.
//  Copyright © 2015年 Ninty. All rights reserved.
//

import UIKit
import AVFoundation

protocol VoicePlayerManagerDelegate: class {
    func playerManager(manager: VoicePlayerManager, didFinishPlaying success: Bool, path: String)
}

class VoicePlayerManager: NSObject {
    static let sharedInstance: VoicePlayerManager = {
        let instance = VoicePlayerManager()
        instance.changeProximityMonitorEnableState(true)
        UIDevice.currentDevice().proximityMonitoringEnabled = false
        return instance
    }()
    
    var playingFilePath: String?
    weak var delegate: VoicePlayerManagerDelegate?
    
    private var player: AVAudioPlayer!
    
    deinit {
        changeProximityMonitorEnableState(false)
    }
    
    func playVoiceByFilePath(path: String) {
        if let pl = player where pl.playing {
            player.stop()
            delegate?.playerManager(self, didFinishPlaying: true, path: path)
        }
        
        playingFilePath = path
        
        AudioSessionManager.setAudioSessionCategory(AVAudioSessionCategoryPlayback)
        do {
            player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
            player.delegate = self
            player.play()
            UIDevice.currentDevice().proximityMonitoringEnabled = true
        } catch {
            print("\(error)")
        }
    }
    
    func changeProximityMonitorEnableState(enable: Bool) {
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        if UIDevice.currentDevice().proximityMonitoringEnabled {
            if enable {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VoicePlayerManager.onProximityStateChange(_:)), name: UIDeviceProximityStateDidChangeNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(self)
                UIDevice.currentDevice().proximityMonitoringEnabled = false
            }
        }
    }
    
    func onProximityStateChange(note: NSNotification) {
        if UIDevice.currentDevice().proximityState {
            AudioSessionManager.setAudioSessionCategory(AVAudioSessionCategoryPlayAndRecord)
        } else {
            AudioSessionManager.setAudioSessionCategory(AVAudioSessionCategoryPlayback)
            if player == nil ||  player.playing == false {
                UIDevice.currentDevice().proximityMonitoringEnabled = false
            }
        }
    }
}

extension VoicePlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerManager(self, didFinishPlaying: flag, path: player.url!.path!)
        
        #if false
        // delete temp file
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), { [weak self] in
            if let path = self?.playingFilePath {
                let fm = NSFileManager.defaultManager()
                let exist = fm.fileExistsAtPath(path)
                if exist {
                    do {
                        try fm.removeItemAtPath(path)
                    } catch {
                        print("\(error)")
                    }
                }
            }
        })
        #endif
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    }
}
