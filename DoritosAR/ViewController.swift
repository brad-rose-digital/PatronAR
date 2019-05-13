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
    var bottleNodeArray : NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottleNodeArray = NSMutableArray.init()
        
        //Create the AR Scene view
        createARView()
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
                self.bottleNodeArray.add(bottleNode)
                
                //Get the height of the bounding box
                let (min, max) = bottleNode.boundingBox
                let height = max.y - min.y
                
                //Get the name of the object
                let objectName = objectAnchor.referenceObject.name
                
                //Add a label above the bounding box
                let textNode = self.createTextNode(string: objectName ?? "")
                let bottleVector = bottleNode.position
                let newVector = SCNVector3Make(bottleVector!.x, height, bottleVector!.z)
                textNode.position = newVector
                self.sceneView?.scene.rootNode.addChildNode(textNode)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouchLocation = touches.first?.location(in: self.sceneView!)
        let hitTestNode = self.sceneView!.hitTest(currentTouchLocation!, options: nil).first?.node
        for node in bottleNodeArray {
            let currentNode = node as! SCNNode
            if hitTestNode == currentNode {
                print("We hit \(currentNode.name ?? "")")
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

