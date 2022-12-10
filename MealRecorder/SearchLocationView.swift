//
//  SearchLocationView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 3.12.2022.
//

import SwiftUI
import CoreLocation
import MapKit
import CoreLocationUI

struct SearchLocationView: View {
    
    @State private var locations: [MapItem] = []
    @State private var searchKeywords = ""
    @Binding var selectedLocation: MapItem?
    let manager = CLLocationManager()
    @State private var userLocation : CLLocation? = nil
    @State private var showSearchPop = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack{
                List(filterLocations()) { location in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Place:").bold()
                            Text("Distance:").bold()
                            Text("Address:").bold()
                        }
                        VStack(alignment: .leading) {
                            Text(location.item.placemark.name ?? "Unknown Place")
                            Text(calculateDistance(from: location.item.placemark.location))
                            Text(location.item.placemark.title ?? "Unknown Place")
                        }
                    }
                    .onTapGesture {
                        selectedLocation = location
                        dismiss()
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSearchPop.toggle()
                        } label: {
                            Text("Search")
                        }
                        
                    }
                })
                .alert("Search Place", isPresented: $showSearchPop, actions: {
                    TextField("eg. Starbucks", text: $searchKeywords)
                    Button("OK", action: {
                        searchPlace(with: searchKeywords)
                    })
                    
                })
            }
            .navigationTitle(Text("Search Place"))
            .onAppear{
                askUserLocation()
        }
        }
        .navigationBarTitleDisplayMode(.large)
    }
    
    func askUserLocation(){
        manager.requestWhenInUseAuthorization()
        if manager.authorizationStatus == .authorizedWhenInUse {
            userLocation = manager.location
            
        }
    }
    
    func filterLocations() -> [MapItem] {
        return locations.filter({ item in
            if let userLocation, let location = item.item.placemark.location{
                return userLocation.distance(from: location) <= 30_000
            } else {
                return true
            }
        })
    }
    
    func calculateDistance(from location: CLLocation?) -> String {
        if let userLocation, let location{
            let distance = location.distance(from: userLocation)
            if distance > 1000 {
                return "\(Int(distance / 1000)) km"
            } else {
                return "\(Int(distance)) m"
            }
        }
        return ""
    }
    
    
    
    func searchPlace(with keyword: String){
        self.locations.removeAll()
        let request = MKLocalSearch.Request()
        if let userLocation{
            request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
        }
        request.naturalLanguageQuery = keyword
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error {
                print(error)
            } else if let response{
                for item in response.mapItems{
                    let location = MapItem(item: item)
                    self.locations.append(location)
                }
            }
        }
    }
}

struct SearchLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchLocationView(selectedLocation: .constant(.init(item: .init())))
        }
    }
}

struct MapItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let item : MKMapItem
}
