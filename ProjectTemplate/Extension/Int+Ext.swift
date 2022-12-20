//
//  Int+Ext.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 01/12/2022.
//

import Foundation

extension Int {
    func degreesToRads() -> Double {
        return (Double(self) * .pi / 180)
    }
}

func startAndEndPointsFrom(angle: Int) -> (startPoint:CGPoint, endPoint:CGPoint) {
    var startPointX:CGFloat = 0.5
    var startPointY:CGFloat = 1.0
    var startPoint:CGPoint
    var endPoint:CGPoint
    switch true {
    case angle == 0:
        startPointX = 0.5
        startPointY = 1.0
    case angle == 45:
        startPointX = 0.0
        startPointY = 1.0
    case angle == 90:
        startPointX = 0.0
        startPointY = 0.5
    case angle == 135:
        startPointX = 0.0
        startPointY = 0.0
    case angle == 180:
        startPointX = 0.5
        startPointY = 0.0
    case angle == 225:
        startPointX = 1.0
        startPointY = 0.0
    case angle == 270:
        startPointX = 1.0
        startPointY = 0.5
    case angle == 315:
        startPointX = 1.0
        startPointY = 1.0
    case angle > 315 || angle < 45:
        startPointX = 0.5 - CGFloat(tan(angle.degreesToRads()) * 0.5)
        startPointY = 1.0
    case angle > 45 && angle < 135:
        startPointX = 0.0
        startPointY = 0.5 + CGFloat(tan(90.degreesToRads() - angle.degreesToRads()) * 0.5)
    case angle > 135 && angle < 225:
        startPointX = 0.5 - CGFloat(tan(180.degreesToRads() - angle.degreesToRads()) * 0.5)
        startPointY = 0.0
    case angle > 225 && angle < 359:
        startPointX = 1.0
        startPointY = 0.5 - CGFloat(tan(270.degreesToRads() - angle.degreesToRads()) * 0.5)
    default: break
    }
    startPoint = CGPoint(x: startPointX, y: startPointY)
    endPoint = startPoint.opposite()
    return (startPoint, endPoint)
}
