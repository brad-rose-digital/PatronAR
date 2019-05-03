//
//  UIView+Extension.swift
//  DoritosAR
//
//  Created by Brad Chessin on 4/29/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        let customBounds = CGRect.init(x: self.bounds.size.width / 2.0, y: self.bounds.origin.y, width: self.bounds.size.width, height: self.bounds.size.height)
        drawHierarchy(in: customBounds, afterScreenUpdates: false)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
