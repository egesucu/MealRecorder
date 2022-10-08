//
//  MealList.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

struct MealListView: View {
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [
                    NSSortDescriptor(keyPath: \Meal.date, ascending: true)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    
    @State private var showAddMeal = false
    
    var body: some View{
        NavigationView{
            ZStack(alignment: .bottomTrailing) {
                ShowView()
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            EditButton()
                                .disabled(meals.count == 0)
                        }
                    })
                    .navigationTitle(Text("Meals"))
                    
                Button {
                    self.showAddMeal.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.largeTitle)
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                .shadow(color: Color(uiColor: .systemOrange), radius: 8, x: 4, y: 4)
                .sheet(isPresented: $showAddMeal, onDismiss: {
                    }, content: {
                        AddMealView()
                            .environment(\.managedObjectContext,context)
                })
                .offset(x: -15, y: -15)
            }
            
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    func ShowView() -> some View {
        if meals.count == 0 {
            VStack {
                Text("No meal is added.").bold()
            }
        } else {
            List {
                Section{
                    ForEach(meals) { meal in
                        MealCell(meal: meal)
                    }.onDelete { index in
                        self.deleteMeal(mealList: meals as? [Meal] ?? [], at: index)
                    }
                } header: {
                    Text("Today")
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    

    
    func deleteMeal(mealList: [Meal], at offsets: IndexSet){
        for index in offsets{
            let item = mealList[index]
            context.delete(item)
            PersistenceController.save(context: context)
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

