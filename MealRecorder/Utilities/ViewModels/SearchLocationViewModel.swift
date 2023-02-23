//
//  SearchLocationViewModel.swift
//  MealRecorder
//
//  Created by Ege Sucu on 23.02.2023.
//

import SwiftUI
import MapKit
import CoreLocation

class SearchLocationViewModel: ObservableObject {

    @Published var locations: [MapItem] = []
    @Published var searchKeywords = ""
    @Published var showSearchPop = true
    let manager = CLLocationManager()
    var userLocation: CLLocation?

    func askUserLocation() {
        manager.requestWhenInUseAuthorization()
        if manager.authorizationStatus == .authorizedWhenInUse {
            userLocation = manager.location
        }
    }

    func filterLocations() -> [MapItem] {
        return locations.filter({ item in
            if let userLocation, let location = item.item.placemark.location {
                return userLocation.distance(from: location) <= 30_000
            } else {
                return true
            }
        })
    }

    func calculateDistance(from location: CLLocation?) -> String {
        if let userLocation, let location {
            let distance = location.distance(from: userLocation)
            if distance > 1_000 {
                return "\(Int(distance / 1_000)) km"
            } else {
                return "\(Int(distance)) m"
            }
        }
        return "N/A"
    }

    func searchPlace() {
        self.locations.removeAll()
        let request = MKLocalSearch.Request()
        if let userLocation {
            request.region = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 1_000, longitudinalMeters: 1_000)
        }
        request.naturalLanguageQuery = searchKeywords
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error {
                print(error)
            } else if let response {
                for item in response.mapItems {
                    let location = MapItem(item: item)
                    self.locations.append(location)
                }
            }
        }
    }

    func createMapRegion(from location: MapItem) -> MKCoordinateRegion {
        let coordinate = location.item.placemark.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
        return MKCoordinateRegion(center: coordinate, span: span)
    }

    func createCoordinate(from location: MapItem) -> CLLocationCoordinate2D {
        return location.item.placemark.coordinate

    }

    func popSearchAlert() {
        showSearchPop.toggle()
    }
}
