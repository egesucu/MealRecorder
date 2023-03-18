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
    @State private var shouldShowImage = false

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
                    .padding([.leading, .trailing], 10)
                if let date = meal.date {
                    mealCellDateLabelView(date: date)
                }
            }
        }
        .alert(isPresented: $showError, content: showGenericError)
        .onAppear(perform: updateLocation)
        .sheet(isPresented: $shouldShowImage) {
            if let data = meal.image,
            let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .shadow(radius: 8)
                    .padding(.all)
            }
        }
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

    func showImage() {
        shouldShowImage.toggle()
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
                        Spacer()
                    }
                }
            }
        }
        .padding(.all)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(10)
    }

    @ViewBuilder
    func mealCellLocationView(location: Location) -> some View {
        HStack(spacing: 0) {
            Map(
                coordinateRegion: $locationRegion,
                interactionModes: [], annotationItems: [location],
                annotationContent: { _ in
                    MapMarker(coordinate: locationCoordination)
                })
            .onChange(of: locationRegion.center.latitude, perform: { _ in updateLocation()})
            .onTapGesture(perform: openLocationInMaps)
            if let data = meal.image,
            let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture(perform: showImage)
            }
        }
        .frame(height: 110)
        .cornerRadius(10, corners: [.topLeft, .topRight])

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
        return Group {
            MealCell(meal: Meal.createMeal(context: PersistenceController.preview.container.viewContext))
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
