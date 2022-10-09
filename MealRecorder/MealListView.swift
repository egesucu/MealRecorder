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
            VStack{
                ShowView()
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            EditButton()
                                .disabled(meals.count == 0)
                            
                            Button {
                                self.showAddMeal.toggle()
                            } label: {
                                Label("Add Meal", systemImage: showAddMeal ? "plus.circle.fill" : "plus.circle")
                            }

                        }
                    })
                    .navigationTitle(Text("Meals"))
            }
            .sheet(isPresented: $showAddMeal, onDismiss: {
                }, content: {
                    AddMealView()
                        .environment(\.managedObjectContext,context)
            })
            
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
                    }
                    .onDelete(perform: deleteMeal)
                } header: {
                    Text("Today")
                }
                .listRowBackground(Color.clear)
            }
            
            .listStyle(.insetGrouped)
        }
    }
    

    func deleteMeal(at offsets: IndexSet){
        for offset in offsets{
            context.delete(meals[offset])
            PersistenceController.save(context: context)
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

