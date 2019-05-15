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
import SceneKit

class ViewController: UIViewController {
    
    var sceneView: ARSCNView?
    
    var planes = [ARPlaneAnchor: Plane]()
    var bottleNodeMap : NSMutableDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create our dictionary of nodes and their associated "names" (keys)
        bottleNodeMap = NSMutableDictionary.init()
        
        //Create the AR Scene view
        createARView()
        
        //Add a tap gesture recognizer on the view to detect a user tapping on objects
        let tap = UITapGestureRecognizer(target: self, action: #selector(search))
        self.sceneView!.addGestureRecognizer(tap)
    }
    
    @objc func search(sender: UITapGestureRecognizer) {
        
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1])
        
        guard sender.state == .ended else { return }
        
        for result in results {
            for (name, node) in bottleNodeMap {
                if result.node.hasAncestor(node as! SCNNode) {
                    let nodeName = name as! String
                    let nodeMessage = "You tapped on: " + nodeName
                    self.showAlert(title: nodeName, msg: nodeMessage)
                    return
                }
            }
        }
    }
    
    func createARView() {
        sceneView = ARSCNView.init(frame: view.frame)
        sceneView?.delegate = self
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView?.autoenablesDefaultLighting = true
        sceneView?.automaticallyUpdatesLighting = true
        sceneView?.showsStatistics = true
        self.view.addSubview(sceneView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load reference images to look for from "AR Resources" folder
        guard let detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.detectionObjects = detectionObjects
            sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }

}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let objectAnchor = anchor as? ARObjectAnchor {
                //Create A Bounding Box Around Our Object
                let scale = CGFloat(objectAnchor.referenceObject.scale.x)
                let bottleNode = BoundingBox(points: objectAnchor.referenceObject.rawFeaturePoints.points, scale: scale)
                node.addChildNode(bottleNode)
                
                //Get the height of the bounding box
                let (min, max) = bottleNode.boundingBox
                let height = max.y - min.y
                
                //Get the name of the object
                let objectName = objectAnchor.referenceObject.name
                bottleNode.name = objectName
                
                //Add our node to our bottle node array
                self.bottleNodeMap.setObject(bottleNode, forKey: objectName! as NSCopying)
                
                //Add a label above the bounding box
                let textNode = self.createTextNode(string: objectName ?? "")
                textNode.centerNode()
                let newVector = SCNVector3Make(0, height, 0)
                textNode.position = newVector
                bottleNode.addChildNode(textNode)
            }
            
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    //MARK: Plane Adding / Updating / Removing
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        planes[anchor] = plane
        plane.setPlaneVisibility(true)
        
        node.addChildNode(plane)
        print("Added plane: \(plane)")
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
}

