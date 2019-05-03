//
//  AudioManager.swift
//  DoritosAR
//
//  Created by Brad Chessin on 5/1/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit

class AudioManager: NSObject {
    
    private var audioStreamer: AudioStreamer?
    private var processTimer : Timer?
    
    func startProcessingAudio() {
        //Initialize our audio streamer object
        audioStreamer = AudioStreamer.init()
        audioStreamer?.startProcessingAudio()
        
        if (processTimer != nil) {
            processTimer?.invalidate()
            processTimer = nil
        }
        processTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.shouldProcessAudio), userInfo: nil, repeats: true)
    }
    
    func stopProcessingAudio() {
        if (processTimer != nil) {
            processTimer?.invalidate()
            processTimer = nil
        }
        audioStreamer?.stopProcessingAudio()
    }
    
    func plotAudioGraph(rect: CGRect, view: UIView) {
        audioStreamer?.plotAudioGraph(rect: rect, view: view)
    }
    
    @objc func shouldProcessAudio() {
        let scoresArray : NSMutableArray = NSMutableArray.init()
        
        //Get the current plot
        let currentPlot = audioStreamer?.currentPlot()
        
        //Get the image of the current plot
        let plotImage = currentPlot?.takeScreenshot()
        
        //Process the scores array here
        
        
    }
    
}
