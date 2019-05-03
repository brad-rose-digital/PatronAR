//
//  ViewController.swift
//  DoritosAR
//
//  Created by iBrad on 2/20/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit
import AVFoundation

import ARKit

import AudioKit
import AudioKitUI

class ViewController: UIViewController {
    
    var audioManager: AudioManager?
    var sceneView: ARSCNView?
    var swipeRight: UISwipeGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the AR Scene view
        createARView()
        
        //Initialize our audio streamer object
        audioManager = AudioManager.init()
        audioManager?.startProcessingAudio()
        
        //Use compiler directives to see if we need to tell the model to show the audio graph
        #if DEBUG
        //Add a audio plot on the bottom of the scene
        let viewH = self.view.frame.size.height; let viewW = self.view.frame.size.width
        let debugViewHeight : CGFloat = 200.0
        let padding : CGFloat = 10.0
        let debugRect = CGRect.init(x: 0.0,
                                    y: viewH - debugViewHeight - padding,
                                    width: viewW,
                                    height: debugViewHeight)
        audioManager?.plotAudioGraph(rect: debugRect, view: self.view)
        
        //Add a swipe right gesture to get to the recording screen
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goToRecordingView))
        swipeRight!.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight!)
        #endif
    }
    
    @objc func goToRecordingView() {
        let mainVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RecordingView")
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
    
    func createARView() {
        sceneView = ARSCNView.init(frame: view.frame)
        self.view.addSubview(sceneView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView?.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }

}

