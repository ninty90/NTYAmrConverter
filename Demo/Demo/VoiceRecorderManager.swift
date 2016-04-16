//
//  RecorderManager.swift
//  Demo
//
//  Created by little2s on 15/10/15.
//  Copyright © 2015年 Ninty. All rights reserved.
//

import Foundation
import AVFoundation

protocol VoiceRecordManagerDelegate: class {
    func didRecordStopForDuration(manager: VoiceRecorderManager)
    func recorderManager(manager: VoiceRecorderManager, didUpdatePeakPowerForChannel peakPower: Double)
}

class VoiceRecorderManager: NSObject {
    weak var delegate: VoiceRecordManagerDelegate?
    
    var maxRecordDuration: NSTimeInterval = 60
    var recordedAudioFileName: String?
    var recordedAudioURL: NSURL?
    var recordedAudioPath: String?
    var recordedAudioDuration: NSTimeInterval = 0
    
    private var recorder: AVAudioRecorder!
    private var timer: NSTimer?
    private var isPause = false
    
    // MARK: Public methods
    func prepareRecord(filePath: String? = nil,  handler: () -> Bool) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), { [unowned self] in
            self.setupAndPrepareToRecord(filePath)
            dispatch_async(dispatch_get_main_queue(), {
                if !handler() {
                    self.cancelRecord()
                }
            })
        })
    }
    
    func startRecord(handler: (() -> Void)? = nil) {
        guard let rd = recorder else {
            return
        }
        
        rd.meteringEnabled = true
        rd.recordForDuration(maxRecordDuration)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(VoiceRecorderManager.timerHandler(_:)), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
        dispatch_async(dispatch_get_main_queue(), {
            handler?()
        })
    }
    
    func stopRecord(handler: (() -> Void)? = nil) {
        isPause = false
        stopRecording()
        getDurationOfLastRecord()

        dispatch_async(dispatch_get_main_queue(), {
            handler?()
        })
    }
    
    func pauseRecord(handler: (() -> Void)? = nil) {
        isPause = true
        if let rd = recorder {
            rd.pause()
            if rd.recording == false {
                dispatch_async(dispatch_get_main_queue(), {
                    handler?()
                })
            }
        }
    }
    
    func resumeRecord(handler: (() -> Void)? = nil) {
        isPause = false
        if let rd = recorder {
            let success = rd.record()
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    handler?()
                })
            }
        }
    }
    
    func cancelRecord(handler: (() -> Void)? = nil) {
        isPause = false
        stopRecording()
        
        // delete temp file
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if let path = self.recordedAudioPath {
                let fm = NSFileManager.defaultManager()
                let exist = fm.fileExistsAtPath(path)
                if exist {
                    do {
                        try fm.removeItemAtPath(path)
                        handler?()
                    } catch {
                        print("\(error)")
                    }
                }
            }
        }
    }
    
    // MARK: Private methods
    private func setupAndPrepareToRecord(filePath: String? = nil) {
        AudioSessionManager.setAudioSessionCategory(AVAudioSessionCategoryPlayAndRecord)
        
        if let path = filePath {
            recordedAudioURL = NSURL.fileURLWithPath(path)
            recordedAudioFileName = recordedAudioURL?.lastPathComponent
            recordedAudioPath = path
        } else {
            let fileName = NSUUID().UUIDString + ".wav"
            let pathComponents = [NSTemporaryDirectory(), fileName]
            recordedAudioURL = NSURL.fileURLWithPathComponents(pathComponents)
            recordedAudioPath = recordedAudioURL?.path
            recordedAudioFileName = fileName
        }
        
        // settings for the recoder
        let recordSettings =  [
            AVFormatIDKey: NSNumber(int: Int32(kAudioFormatLinearPCM)),
            AVSampleRateKey: 8000.0,
            AVLinearPCMBitDepthKey: 16,
            AVNumberOfChannelsKey: 1,
        ]
        
        do {
            recorder = try AVAudioRecorder(URL: recordedAudioURL!, settings: recordSettings)
            recorder.prepareToRecord()
        } catch {
            print("\(error)")
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func cancelRecording() {
        if let rd = recorder where rd.recording {
            rd.stop()
        }
        recorder = nil
    }
    
    private func stopRecording() {
        cancelRecording()
        resetTimer()
    }
    
    private func getDurationOfLastRecord() {
        guard let url = recordedAudioURL else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOfURL: url)
            recordedAudioDuration = player.duration
        } catch {
            print("\(error)")
        }
    }
    
    func timerHandler(sender: AnyObject) {
        guard let rd = recorder else {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            rd.updateMeters()
            
            let averagePower = rd.averagePowerForChannel(0)
            let peakPowerForChannel = pow(10, Double(averagePower) * 0.015)
            
            dispatch_async(dispatch_get_main_queue(),  { [unowned self] in
                self.delegate?.recorderManager(self, didUpdatePeakPowerForChannel: peakPowerForChannel)
            })
            
            if rd.currentTime > self.maxRecordDuration {
                self.stopRecording()
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.delegate?.didRecordStopForDuration(self)
                })
            }
        })
    }
}

