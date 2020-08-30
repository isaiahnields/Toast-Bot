//
//  FireParticle.swift
//  Roast Bot
//
//  Created by isaiahnields on 6/22/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit

class ParticleView: UIView {
    private var particleImage: UIImage
    private var birthRates: (Float, Float, Float)
    private var velocities: (Float, Float, Float)
    private var emitter: CAEmitterLayer?
    
    private var near: CAEmitterCell?
    private var middle: CAEmitterCell?
    private var far: CAEmitterCell?
    
    override class var layerClass:AnyClass {
        return CAEmitterLayer.self
    }
    
    init(birthRates: (Float, Float, Float), velocities: (Float, Float, Float), frame: CGRect, particleImage: UIImage) {
        self.birthRates = birthRates
        self.velocities = velocities
        self.particleImage = particleImage
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeEmmiterCell(color:UIColor, velocity:CGFloat, scale:CGFloat)-> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 0.2
        cell.lifetime = 20.0
        cell.lifetimeRange = 0
        cell.velocity = velocity
        cell.velocityRange = velocity / 4
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 16
        cell.scale = scale
        cell.scaleRange = scale / 3
        cell.contents = particleImage.cgImage
        return cell
    }
    
    override func layoutSubviews() {
        self.emitter = self.layer as? CAEmitterLayer
        emitter!.masksToBounds = true
        emitter!.emitterShape = .line
        emitter!.emitterPosition = CGPoint(x: bounds.midX, y: -50)
        emitter!.emitterSize = CGSize(width: bounds.size.width, height: 1)
        
        self.near = makeEmmiterCell(color: UIColor(white: 1, alpha: 1), velocity: 100, scale: 0.2)
        self.middle = makeEmmiterCell(color: UIColor(white: 1, alpha: 1), velocity: 80, scale: 0.15)
        self.far = makeEmmiterCell(color: UIColor(white: 1, alpha: 1), velocity: 90, scale: 0.175)
        self.near!.birthRate = self.birthRates.0
        self.middle!.birthRate = self.birthRates.1
        self.far!.birthRate = self.birthRates.2
        
        self.near!.velocity = CGFloat(self.velocities.0)
        self.middle!.velocity = CGFloat(self.velocities.1)
        self.far!.velocity = CGFloat(self.velocities.2)
        
        emitter!.emitterCells = [self.near!, self.middle!, self.far!]
    }
}
