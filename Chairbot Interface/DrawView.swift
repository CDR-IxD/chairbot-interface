//
//  DrawView.swift
//  Chairbot Interface
//
//  Created by Abhay Venkatesh on 6/26/17.
//  Copyright © 2017 Stanford CDR. All rights reserved.
//

import UIKit

class DrawView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var lines: [Line] = []
    var lastPoint: CGPoint!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first?.location(in: self)
        lines.append(Line(start: lastPoint, end: newPoint!))
        lastPoint = newPoint
        
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.beginPath()
        for line in lines {
            context?.move(to: CGPoint(x: line.start.x, y: line.start.y))
            context?.addLine(to: CGPoint(x: line.end.x, y: line.end.y))
        }
        context!.setLineCap(CGLineCap.round)
        context!.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context!.setLineWidth(5)
        context!.strokePath()
    }
    
    func sendLines(_ lines: [Line]) {

    }
    

}
