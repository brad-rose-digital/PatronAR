//
//  AudioStreamer.swift
//  DoritosAR
//
//  Created by Brad Chessin on 4/29/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class AudioStreamer: NSObject {
    
    //MARK: Interal Variables
    private var mic: AKMicrophone!
    private var tracker: AKFrequencyTracker!
    private var silence: AKBooster!
    
    private var micMixer: AKMixer!
    private var recorder: AKNodeRecorder!
    private var moogLadder: AKMoogLadder!
    private var mainMixer: AKMixer!
    
    private var audioInputPlot: EZAudioPlot?
    
    required override init() {
        super.init()
        
        //Initialize our AudioKit variables
        try! AKSettings.setSession(category: .playAndRecord)
        AKSettings.audioInputEnabled = true
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .veryLong
        
        //Initialize the microhone
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
        //Initialize the recorder
        let monoToStereo = AKStereoFieldLimiter(mic, amount: 1)
        micMixer = AKMixer(silence, monoToStereo)
        recorder = try? AKNodeRecorder(node: micMixer)
        AudioKit.output = micMixer
    }
    
    //MARK: Start/Stop Processing Audio
    func startProcessingAudio() {
        setupPlot()
        do {
            try recorder.record()
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    func stopProcessingAudio() {
        recorder.stop()
        removePlot()
    }
    
    //MARK: Plot related methods
    func setupPlot() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let microphoneFrame = CGRect.init(x: 0.0, y: 0.0, width: screenWidth, height: 200.0)
        
        /*
        For instance, for a sample rate = 44100 the microphone callback will trigger ~86 times a second (44100 frames per sec / 512 frames per callback ). So a rolling history length of 1024 will correspond to displaying about 11.9 seconds of audio. Hence, you can calculate the required rolling history length using the formula:
        */
        let samplesPerSecond = 86
        let secondsToRecord = 3
        let rollingHistoryLength = Int32(samplesPerSecond * secondsToRecord)
        
        //Create the EZAudioPlot
        audioInputPlot = EZAudioPlot.init()
        audioInputPlot?.shouldOptimizeForRealtimePlot = true
        audioInputPlot?.frame = microphoneFrame
        audioInputPlot?.setRollingHistoryLength(rollingHistoryLength)
        
        //Create the output plot
        let microphonePlot = AKNodeOutputPlot(mic, frame: audioInputPlot!.bounds)
        microphonePlot.plotType = .rolling
        microphonePlot.gain = 3.0
        microphonePlot.shouldFill = true
        microphonePlot.shouldMirror = true
        microphonePlot.color = UIColor.blue
        audioInputPlot?.addSubview(microphonePlot)
    }
    
    func plotAudioGraph(rect: CGRect, view: UIView) {
        audioInputPlot?.frame = rect
        view.addSubview(audioInputPlot!)
    }
    
    func removePlot() {
        audioInputPlot = nil
    }
    
    func currentPlot() -> EZAudioPlot? {
        return audioInputPlot
    }
}
