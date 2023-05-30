//
//  CircularProgressView.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 28/05/23.
//

import UIKit
import AVFoundation

class CircularProgressView: UIView {

    // MARK: - Properties
    var progressLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!
    var pulsatinLayer: CAShapeLayer!
    var audioPlayer: AVAudioPlayer?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurecircleLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        audioPlayer = nil
    }

    // MARK: - Helpers
    func configurecircleLayers() {
        pulsatinLayer = circleShapeLayer(strokeColor: .clear, fillColor: .mainBlueTint.withAlphaComponent(0.5))
        layer.addSublayer(pulsatinLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        
        progressLayer.strokeEnd = 1
    }

    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: self.frame.width / 2.5,
                                        startAngle: -( .pi / 2),
                                        endAngle: 1.5 * .pi, clockwise: true)

        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center

        return layer
    }

    func animatePulsatingLAyer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatinLayer.add(animation, forKey: "pulsing")
    }

    func setProgressWithAnimationDuration(duration: TimeInterval,
                                          toValue: Float, completion: @escaping() -> Void){
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 1
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(toValue)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }

    func playAudio() {
        let url = Bundle.main.url(forResource: "uber_sound", withExtension: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer?.numberOfLoops = 3
        audioPlayer?.play()
    }
}
