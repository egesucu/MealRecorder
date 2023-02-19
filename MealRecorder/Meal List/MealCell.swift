//
//  MealCell.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import MapKit

struct MealCell: View {

    var meal: Meal
    @State private var locationRegion: MKCoordinateRegion = .init()
    let locationSpan = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
    @State private var locationCoordination = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGroupedBackground))
                .shadow(color: .gray, radius: 4)
            VStack(alignment: .center) {
                if let location = meal.selectedLocation {
                    Map(
                        coordinateRegion: $locationRegion,
                        interactionModes: [], annotationItems: [location],
                        annotationContent: { _ in
                            MapMarker(coordinate: locationCoordination)

                    })
                    .onChange(of: locationRegion.center.latitude, perform: { _ in
                        updateLocation()
                    })
                    .frame(height: 110)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .onTapGesture {
                        let url = URL(string: "maps://?saddr=&daddr=\(location.latitude),\(location.longitude)")
                        if let url {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                }

                Text(meal.mealType.text())
                    .font(.title)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading) {
                    ForEach(meal.items ?? [""], id: \.self) { item in
                        HStack {
                            Label(item, systemImage: "largecircle.fill.circle")
                                .padding(.bottom, 3)
                        }
                    }
                }
                .padding(.all)
                .background(.white)
                .cornerRadius(10)
                if let date = meal.date {
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
        }.onAppear(perform: updateLocation)

    }

    func updateLocation() {
        if let location = meal.selectedLocation {
            locationRegion.center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            locationRegion.span = locationSpan
            locationCoordination = locationRegion.center
        }
    }

}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {

        let meal = Meal(context: PersistenceController.preview.container.viewContext)
        meal.items = ["Cake", "Burger"]
        meal.date = Date.now
        let demoLocation = Location(context: PersistenceController.preview.container.viewContext)
        demoLocation.name = "Starbucks"
        demoLocation.latitude = 41.032464900467325
        demoLocation.longitude = 28.964352429812604
        meal.selectedLocation = demoLocation

        return Group {
            MealCell(meal: meal)
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
        }

    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
