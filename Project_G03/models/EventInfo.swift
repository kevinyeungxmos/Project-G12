//
//  EventInfo.swift
//  Project_G03
//
//  Created by user241431 on 7/1/23.
//

import Foundation
import FirebaseFirestoreSwift

struct EventInfo: Codable, Hashable{
    
    var id: Int?
    var title: String
    var performer: String
    var date: String
    var img: String
    var venue: String
    var address: String
    var city: String
    var lat: String
    var lon: String
    var price: String
    var url: String
    var friendAlsoAttend = [UserInfo]()
    
    init(id: Int? = nil, title: String, performer: String, date: String, img: String, venue: String, address: String, city: String, lat: String, lon: String, price: String, url: String) {
        self.id = id
        self.title = title
        self.performer = performer
        self.date = date
        self.img = img
        self.venue = venue
        self.address = address
        self.city = city
        self.lat = lat
        self.lon = lon
        self.price = price
        self.url = url
    }
    
}
