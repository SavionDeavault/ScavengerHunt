//
//  PropertyManager.swift
//  ScavengerHunt
//
//  Created by Savion DeaVault on 12/3/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import Foundation
import MapKit

class PropertyManager{
    
static let instance = PropertyManager()

var activityType: String? = ""
var stepsCount: String? = ""

var hasCirclesBeenGenerated : Bool = false
var circlesArray: [CLLocation] = []
var circleRadius: Int!
var circlesGenerated: Int = 0
var maxCircles: Int = 10
var timeUntilCircleCheck: Int = 10
    
    private init(){
        print("Property Manager called!")
    }
}
