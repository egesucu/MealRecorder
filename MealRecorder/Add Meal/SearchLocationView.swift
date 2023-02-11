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
    let manager = CLLocationManager()
    @State private var userLocation : CLLocation? = nil
    @State private var showSearchPop = true
    @Environment(\.dismiss) var dismiss
    @ObservedObject var addMealViewModel: AddMealViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                List(filterLocations()) { location in
                    VStack{
                        Group{
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
                        }
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: .init(latitude: location.item.placemark.coordinate.latitude, longitude: location.item.placemark.coordinate.longitude), span: .init(latitudeDelta: 0.0005, longitudeDelta: 0.0005))), interactionModes: [], annotationItems: [location], annotationContent: { item in
                            MapMarker(coordinate: .init(latitude: location.item.placemark.coordinate.latitude, longitude: location.item.placemark.coordinate.longitude))
                        })
                        .frame(height: 150)
                        .cornerRadius(20)
                    }.onTapGesture {
                        addMealViewModel.updateLocation(location: location)
                        addMealViewModel.updateLocation(location: location.item.name ?? "")
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
                        .autocorrectionDisabled()
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
        return "N/A"
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

struct MapItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let item : MKMapItem
}
