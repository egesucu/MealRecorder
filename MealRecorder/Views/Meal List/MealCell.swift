//
//  MealCell.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import MapKit

struct MealCell: View {

    @State private var locationRegion: MKCoordinateRegion = .init()
    @State private var locationCoordination = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var showError = false
    @State private var alertMessage = ""
    let locationSpan = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
    var meal: Meal

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGroupedBackground))
                .shadow(color: .gray, radius: 4)
            VStack(alignment: .center) {
                if let location = meal.selectedLocation {
                    mealCellLocationView(location: location)
                }
                Text(meal.mealType.text())
                    .font(.title)
                    .multilineTextAlignment(.center)
                mealCellItemsView()
                if let date = meal.date {
                    mealCellDateLabelView(date: date)
                }
            }
        }
        .alert(isPresented: $showError, content: showGenericError)
        .onAppear(perform: updateLocation)
    }

    func updateLocation() {
        if let location = meal.selectedLocation {
            locationRegion.center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            locationRegion.span = locationSpan
            locationCoordination = locationRegion.center
        }
    }

    func openLocationInMaps() {
        if let location = meal.selectedLocation,
           let url = URL(string: "maps://?saddr=&daddr=\(location.latitude),\(location.longitude)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertMessage = "We can't open the map."
        }
    }

}

// MARK: - View Builders
extension MealCell {
    func showGenericError() -> SwiftUI.Alert {
        Alert(title: Text("Error"), message: Text(alertMessage))
    }
    @ViewBuilder
    func mealCellItemsView() -> some View {
        VStack(alignment: .leading) {
            if let items = meal.items {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Label(item, systemImage: "largecircle.fill.circle")
                            .padding(.bottom, 3)
                    }
                }
            }
        }
        .padding(.all)
        .background(.white)
        .cornerRadius(10)
    }

    @ViewBuilder
    func mealCellLocationView(location: Location) -> some View {
        Map(
            coordinateRegion: $locationRegion,
            interactionModes: [], annotationItems: [location],
            annotationContent: { _ in
                MapMarker(coordinate: locationCoordination)

            })
        .onChange(of: locationRegion.center.latitude, perform: { _ in updateLocation()})
        .frame(height: 110)
        .cornerRadius(10, corners: [.topLeft, .topRight])
        .onTapGesture(perform: openLocationInMaps)
    }

    @ViewBuilder
    func mealCellDateLabelView(date: Date) -> some View {
        if Calendar.current.isDateInToday(date) {
            HStack(alignment: .center, spacing: 0) {
                Text("Today at: ")
                Text(date.formatted(.dateTime.hour().minute()))
                    .bold()
            }

        } else {
            Text(date.formatted())
                .bold()
        }
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {

        var meal = Meal(context: PersistenceController.preview.container.viewContext)
        PersistenceController.createMockup(meal: &meal)

        return Group {
            MealCell(meal: meal)
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
