//
//  RecordAndPlayViewController.swift
//  RecorderAndPlayer
//
//  Created by Susan Zheng on 7/15/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAndPlayViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate
{

    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var soundRecorder: AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var audioEngine : AVAudioEngine!
    var audioFile : AVAudioFile!
    
    let fileName = "demo.caf"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupRecorder()
        
        audioEngine = AVAudioEngine()
        
        do {
            
            _ = try AVAudioFile(forReading: getFileURL())
        }
        catch
        {
            print(error)
        }
        
        let audioFileAsset = try! AVAudioFile(forReading: getFileURL())
        
        print(audioFileAsset)
        
    }

    
    @IBAction func record(_ sender: AnyObject)
    {
        if (RecordButton.titleLabel!.text == "Record")
        {
            soundRecorder.record()
            RecordButton.setTitle("Stop", for: UIControlState())
            playButton.isEnabled = false
        }
        else
        {
            soundRecorder.stop()
            RecordButton.setTitle("Record", for: UIControlState())
            playButton.isEnabled = true
        }
        
    }
    
    
    func voiceChanged(_ pitch: Float)
    {
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changePitch = AVAudioUnitTimePitch()
        changePitch.pitch = pitch
        audioEngine.attach(changePitch)
        
        audioEngine.connect(audioPlayerNode, to: changePitch, format: nil)
        audioEngine.connect(changePitch, to: audioEngine.outputNode, format: nil)
        

        
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
    }
 
    
    @IBAction func play(_ sender: AnyObject)
    {
        
        if (playButton.titleLabel!.text == "Play")
        {
            RecordButton.isEnabled = false
            playButton.setTitle("Stop", for: UIControlState())
            preparePlayer()
            soundPlayer.play(voiceChanged(1000))
        }
        else
        {
            soundPlayer.stop()
            playButton.setTitle("Play", for: UIControlState())
        }
    }
    
    
    func setupRecorder()
    {
        
        //settings for recorder
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless) as Int32),
                        AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),
                     AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue) as Int32),
                          AVEncoderBitRateKey : NSNumber(value: 320000 as Int32)];
        
        
        var error: NSError?
        
        do
        {
            soundRecorder =  try AVAudioRecorder(url: getFileURL(), settings: recordSettings)
        }
        catch let error1 as NSError
        {
            error = error1
            soundRecorder = nil
        }
        
        if let err = error
        {
            print("AVAudioRecorder error: \(err.localizedDescription)")
        }
        else
        {
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        }
    }
    
    
    func getCacheDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true)
        return paths[0]
    }

    func getFileURL() -> URL
    {
        let path = getCacheDirectory() + fileName
        let filePath = URL(fileURLWithPath: path)
        
        return filePath
    }
    
    func preparePlayer()
    {
        var error: NSError?
        
        do
        {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL())
        }
        catch let error1 as NSError
        {
            error = error1
            soundPlayer = nil
        }
        
        if let err = error
        {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        }
        else
        {
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
        
        
        
        
        // MARK:- AVAudioPlayer delegate methods
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
        {
            RecordButton.isEnabled = true
            playButton.setTitle("Play", for: UIControlState())
        }
        
        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: NSError?)
        {
            print("Error while playing audio \(error!.localizedDescription)")
        }
        
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
        {
            playButton.isEnabled = true
            RecordButton.setTitle("Record", for: UIControlState())
        }
        
        func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: NSError?)
        {
            print("Error while recording audio \(error!.localizedDescription)")
        }
        
    }

}
