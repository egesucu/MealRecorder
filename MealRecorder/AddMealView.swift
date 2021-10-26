//
//  AddMealView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

struct AddMealView: View {
    
    @State private var name = ""
    @State private var location = ""
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    var body: some View{
        
        NavigationView {
            Form{
                TextField("Meal Name", text: $name, prompt: Text("Meal Name"))
                    .disableAutocorrection(true)
                TextField("Meal Location",text: $location, prompt: Text("Meal Location"))
                DatePicker("Date", selection: $date,displayedComponents: .hourAndMinute)
            }
            .toolbar(content: {
                
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button{
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel").foregroundColor(Color(uiColor: .systemRed))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.saveMeal()
                        } label: {
                            Text("Add")
                                .foregroundColor(Color(uiColor: .systemGreen))
                        }

                    }
                
            })
        .navigationTitle(Text("Add Meal"))
        }
    }
    
    func saveMeal(){
        let meal = Meal(context: context)
        meal.id = UUID()
        meal.name = name
        meal.location = location
        meal.date = date
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss()
        } catch let error {
            print(error.localizedDescription)
        }
       
    }
}


struct AddMealView_Previews: PreviewProvider {
    static var previews: some View {
            AddMealView()
    }
}
