//
//  BoundingBox.swift
//  Patron PoC
//
//  Created by Brad Chessin on 5/7/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class BoundingBox: SCNNode {
    //-----------------------
    // MARK: - Initialization
    //-----------------------
    
    /// Creates A WireFrame Bounding Box From The Data Retrieved From The ARReferenceObject
    ///
    /// - Parameters:
    ///   - points: [float3]
    ///   - scale: CGFloat
    ///   - color: UIColor
    init(points: [float3], scale: CGFloat, color: UIColor = .cyan) {
        super.init()
        
        var localMin = float3(repeating: Float.greatestFiniteMagnitude)
        var localMax = float3(repeating: -Float.greatestFiniteMagnitude)
        
        for point in points {
            localMin = min(localMin, point)
            localMax = max(localMax, point)
        }
        
        self.simdPosition += (localMax + localMin) / 2
        let extent = localMax - localMin
        
        let wireFrame = SCNNode()
        let box = SCNBox(width: CGFloat(extent.x), height: CGFloat(extent.y), length: CGFloat(extent.z), chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        wireFrame.geometry = box
        setupShaderOnGeometry(box)
        self.addChildNode(wireFrame)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) Has Not Been Implemented") }
    
    //----------------
    // MARK: - Shaders
    //----------------
    
    /// Sets A Shader To Render The Cube As A Wireframe
    ///
    /// - Parameter geometry: SCNBox
    func setupShaderOnGeometry(_ geometry: SCNBox) {
        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "art.scnassets"),
            let shader = try? String(contentsOfFile: path, encoding: .utf8) else {
                return
        }
        
        geometry.firstMaterial?.shaderModifiers = [.surface: shader]
    }
}
