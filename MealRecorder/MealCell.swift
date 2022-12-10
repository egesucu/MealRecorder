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
    
    var body: some View{
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGroupedBackground))
                .shadow(color: .gray , radius: 4)
            VStack {
                if let location = meal.selectedLocation{
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: .init(latitude: location.latitude, longitude: location.longitude), span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))), annotationItems: [location], annotationContent: { item in
                        MapMarker(coordinate: .init(latitude: location.latitude, longitude: location.longitude))
                    })
                    .frame(height: 100)
                    .cornerRadius(10, corners: [.topLeft,.topRight])
                    .onTapGesture {
                        let url = URL(string: "maps://?saddr=&daddr=\(location.latitude),\(location.longitude)")
                        if let url{
                            if UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    HStack{
                        if let data = meal.image,
                        let image = UIImage(data: data){
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100 ,height: 100)
                                .cornerRadius(10)
                                .padding([.leading,.trailing],2)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(uiColor: .systemGroupedBackground))
                                    .shadow(radius: 4)
                                Image("no-meal-photo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.all)
                                    
                            }
                            .frame(width: 100 ,height: 100)
                            .padding([.leading,.trailing],2)
                            
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Meals")
                                .font(.title)
                                .bold()
                                .padding(.bottom, 4)
                            ForEach(meal.items ?? [""], id: \.self) { item in
                                HStack{
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
                    }
                    HStack{
                        Text("Date")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text(meal.date?.formatted() ?? "")
                    }
                    if let location = meal.location{
                        HStack{
                            Text("Location")
                                .font(.title3)
                                .bold()
                            Spacer()
                            Text(location)
                        }
                    }
                }.padding(.all)
            }
        }
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        
        let meal = Meal(context: PersistenceController.preview.container.viewContext)
        meal.items = ["Cake","Burger"]
        meal.location = "AVM"
        meal.date = Date.now
        let demoLocation = Location(context: PersistenceController.preview.container.viewContext)
        demoLocation.name = "Starbucks"
        demoLocation.latitude = 41.071464900497325
        demoLocation.longitude = 28.967352429822604
        meal.selectedLocation = demoLocation
        
        return Group{
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
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
