//
//  SKButton.swift
//  pongAlpha
//
//  Created by zzc on 11/10/18.
//  Copyright © 2018 zzc. All rights reserved.
//

import UIKit
import SpriteKit

protocol SKButtonDelegate: class {
    func touchUpInsideSKButton(sender: SKButton)
}

class SKButton: SKSpriteNode {
    weak var delegate: SKButtonDelegate!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate.touchUpInsideSKButton(sender: self)
    }
}
