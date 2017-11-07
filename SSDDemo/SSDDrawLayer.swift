//
//  SSDDrawLayer.swift
//  SSDDemo
//
//  Created by Nicky Chan on 11/7/17.
//  Copyright © 2017 PaddlePaddle. All rights reserved.
//

import UIKit

class SSDDrawLayer: CAShapeLayer {

    
    func render(_ data: SSDData) {
        
        self.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 64, width: 160, height: 160), cornerRadius: 50).cgPath
        self.strokeColor = UIColor.blue.cgColor
        self.lineWidth = 3.0
        self.fillColor = nil
        self.lineJoin = kCALineJoinBevel
    }
    
}
