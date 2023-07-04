//
//  MapMarker.swift
//  Project_G03
//
//  Created by user241431 on 7/3/23.
//

import SwiftUI
import MapKit

struct MMarker: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var show = false
}
