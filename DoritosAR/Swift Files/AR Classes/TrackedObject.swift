//
//  TrackedObject.swift
//  Patron PoC
//
//  Created by Brad Chessin on 5/22/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit
import ARKit

class TrackedObject: NSObject {
    var objectName : String!
    var object : SCNNode!
    var objectAnchor : ARAnchor!
    
    public init(objectName: String, object: SCNNode, objectAnchor: ARAnchor) {
        self.objectName = objectName
        self.object = object
        self.objectAnchor = objectAnchor
    }

}
