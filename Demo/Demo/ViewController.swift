//
//  ViewController.swift
//  Demo
//
//  Created by little2s on 16/4/16.
//  Copyright © 2016年 Chainsea. All rights reserved.
//

import UIKit
import NTYAmrConverter

let fileManager = NSFileManager.defaultManager()
let documentURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
let wavPath = documentURL.URLByAppendingPathComponent("test.wav").path!
let amrPath = documentURL.URLByAppendingPathComponent("test.amr").path!
let convertedWavPath = documentURL.URLByAppendingPathComponent("converted.wav").path!

class ViewController: UIViewController {
    
    let recorderManager = VoiceRecorderManager()
    let playManager = VoicePlayerManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("wavPath: \(wavPath), amrPath: \(amrPath), convertedWavPath: \(convertedWavPath)")
    }

    @IBAction func record(sender: UIButton) {
        print("start record...")
        
        recorderManager.prepareRecord(wavPath) { [weak self] () -> Bool in
            self?.recorderManager.startRecord()
            return true
        }
    }

    @IBAction func stop(sender: UIButton) {
        print("stop record")
        
        recorderManager.stopRecord()
        
        print("ecode wav to amr")
        
        NTYAmrCoder.encodeWavFile(wavPath, toAmrFile: amrPath)
        
    }
    
    @IBAction func Play(sender: UIButton) {
        print("decode amr to wav")
        
        NTYAmrCoder.decodeAmrFile(amrPath, toWavFile: convertedWavPath)
        
        print("play")
        
        playManager.playVoiceByFilePath(convertedWavPath)
    }
}

