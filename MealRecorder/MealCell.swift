//
//  MealCell.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

struct MealCell: View {
    var meal: Meal
    
    var body: some View{
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemGroupedBackground))
                .shadow(radius: 4)
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
                                .frame(width: 100 ,height: 100)
                                .shadow(radius: 4)
                            Image("no-meal-photo")
                                .resizable()
                                .scaledToFit()
                                .padding(.all)
                                
                        }.padding([.leading,.trailing],2)
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
            }.padding(.all)
        }
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        
        let meal = Meal(context: PersistenceController.preview.container.viewContext)
        meal.items = ["Cake","Burger"]
        meal.location = "AVM"
        meal.date = Date.now
        
        return Group{
            MealCell(meal: meal)
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
        }
        
    }
}
