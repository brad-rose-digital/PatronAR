//
//  AnimationLaunchScreen.swift
//  DoritosAR
//
//  Created by Brad Chessin on 4/29/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit
import AVFoundation

class AnimationLaunchScreen: UIViewController {
    
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeVideoPlayerWithVideo()
    }
    
    func initializeVideoPlayerWithVideo() {
        
        // get the path string for the video from assets
        let videoString:String? = Bundle.main.path(forResource: "DoritosAnimation", ofType: "mp4")
        guard let unwrappedVideoPath = videoString else {return}
        
        // convert the path string to a url
        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
        
        // initialize the video player with the url
        self.player = AVPlayer(url: videoUrl)
        self.player?.rate = 1.4
        
        // create notification to know when we should continue to the main view controller
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
        // create a video layer for the player
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        
        // make the layer the same size as the container view
        let viewHeight: CGFloat = 220.0
        let frame = CGRect.init(x: 0, y: self.view.frame.size.height / 2.0 - viewHeight / 2.0, width: self.view.frame.size.width, height: viewHeight)
        layer.frame = frame
        
        // make the video fill the layer as much as possible while keeping its aspect size
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        // add the layer to the container view
        self.view.layer.addSublayer(layer)
        
        // play the video
        player?.play()
    }
    
    @objc func playerDidFinishPlaying() {
        let mainVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainView")
        self.navigationController?.pushViewController(mainVC, animated: false)
    }

}
