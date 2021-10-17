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
        HStack{
            VStack(alignment: .leading) {
                Label {
                    Text(meal.name ?? "")
                } icon: {
                    Image(systemName: "fork.knife")
                        .foregroundColor(Color(uiColor: .systemOrange))
                }
                Spacer(minLength: 20)
                Label {
                    Text(meal.location ?? "")
                } icon: {
                    Image(systemName: "map.fill")
                        .foregroundColor(Color(uiColor: .label))
                }
            }.padding(5)
            Spacer()
            Text((meal.date ?? Date()).formatted(.dateTime.hour().minute()))
            
        }
        
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        
        let meal = Meal(context: PersistenceController.preview.container.viewContext)
        meal.name = "Cake"
        meal.location = "AVM"
        meal.date = Date.now
        
        return Group{
            MealCell(meal: meal)
                .preferredColorScheme(.dark)
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
            MealCell(meal: meal)
                .preferredColorScheme(.light)
                .frame(width: .infinity, height: 80, alignment: .center)
                .padding()
                .previewLayout(.sizeThatFits)
        }
            
    }
}
