//
//  SearchLocationView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 3.12.2022.
//

import SwiftUI
import MapKit

struct SearchLocationView: View {

    @StateObject var slViewModel = SearchLocationViewModel()
    @ObservedObject var addMealViewModel: AddMealViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                List(slViewModel.filterLocations()) { location in
                    VStack {
                        Group {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("Place:")
                                        .bold()
                                    Text("Distance:")
                                        .bold()
                                    Text("Address:")
                                        .bold()
                                }
                                VStack(alignment: .leading) {
                                    Text(location.item.placemark.name ?? "Unknown Place")
                                    Text(slViewModel.calculateDistance(from: location.item.placemark.location))
                                    Text(location.item.placemark.title ?? "Unknown Place")
                                }
                            }
                        }
                        Map(coordinateRegion:
                                .constant(slViewModel.createMapRegion(from: location)),
                            interactionModes: [],
                            annotationItems: [location],
                            annotationContent: { _ in
                            MapMarker(coordinate: slViewModel.createCoordinate(from: location))
                        })
                        .frame(height: 150)
                        .cornerRadius(20)
                    }.onTapGesture {
                        addMealViewModel.updateLocation(location: location)
                        dismiss()
                    }
                }
                .toolbar(content: bottomToolbar)
                .alert("Search Place", isPresented: $slViewModel.showSearchPop, actions: alertView)
            }
            .navigationTitle(Text("Search Place"))
            .onAppear(perform: slViewModel.askUserLocation)
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - View Builders
extension SearchLocationView {
    @ViewBuilder
    func alertView() -> some View {
        TextField("eg. Gloria Jeans", text: $slViewModel.searchKeywords)
            .autocorrectionDisabled()
        Button("OK", action: slViewModel.searchPlace)
    }

    @ToolbarContentBuilder
    func bottomToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Search", action: slViewModel.popSearchAlert)
        }
    }
}
