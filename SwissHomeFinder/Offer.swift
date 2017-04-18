//
//  Offer.swift
//  SwissHomeFinder
//
//  Created by Yannick Heinrich on 18.04.17.
//  Copyright © 2017 yageek. All rights reserved.
//

import Foundation
import MapKit

class Offer: NSObject, MKAnnotation {

    public let offerTitle: String
    public let price: Double
    public dynamic let coordinate: CLLocationCoordinate2D
    public let start: String
    public let address: String
    public let rooms: Double
    public let url: URL
    public let key: String

    init?(json: [String: Any]) {

        guard
        let keyJSON = json["Key"] as? String,
        let urlJSON = json["URL"] as? String,
        let titleJSON = json["Title"] as? String,
        let addressJSON = json["Address"] as? String,
        let priceJSON = json["Price"] as? Double,
        let startJSON = json["Start"] as? String,
        let roomsJSON = json["Rooms"] as? Double,
        let locationJSON = json["Location"] as? [String: Any] else { return nil }

        guard
        let lat = locationJSON["Lat"] as? Double,
            let lng = locationJSON["Lng"] as? Double else { return nil }
        guard let url = URL(string: urlJSON) else { return nil }
        offerTitle = titleJSON
        price = priceJSON
        coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        start = startJSON
        rooms = roomsJSON
        address = addressJSON
        key = keyJSON
        self.url = url
    }


    public var title: String? {
        return offerTitle
    }

    public var subtitle: String? {
        return "\(start)-\(price) CHF - \(rooms) pièces"
    }
    
}
