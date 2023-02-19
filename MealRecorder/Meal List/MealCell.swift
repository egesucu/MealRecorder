//
//  MealCell.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI
import MapKit

struct MealCell: View {

    @GestureState private var scale: CGFloat = 1.0

    var meal: Meal

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGroupedBackground))
                .shadow(color: .gray, radius: 4)
            VStack(alignment: .center) {
                HStack(alignment: .center, spacing: 0) {
                    if let location = meal.selectedLocation {
                        Map(
                            coordinateRegion:
                                    .constant(MKCoordinateRegion(center:
                                            .init(latitude: location.latitude, longitude: location.longitude),
                                                                 span: .init(latitudeDelta: 0.0005,
                                                                             longitudeDelta: 0.0005))),
                            interactionModes: [],
                            annotationItems: [location],
                            annotationContent: { _ in
                                MapMarker(coordinate: .init(latitude: location.latitude, longitude: location.longitude))
                            })

                        .cornerRadius(10, corners: [.topLeft])
                        .onTapGesture {
                            let url = URL(string: "maps://?saddr=&daddr=\(location.latitude),\(location.longitude)")
                            if let url {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }
                }.frame(height: 110)

                HStack {
                    VStack(alignment: .leading) {
                        ForEach(meal.items ?? [""], id: \.self) { item in
                            HStack {
                                Label {
                                    Text(item)
                                } icon: {
                                    Image(systemName: "largecircle.fill.circle")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                    Spacer()
                    Text(meal.date?.formatted() ?? "").bold()
                }.padding(.all)
            }
        }
        .padding(.top)
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
