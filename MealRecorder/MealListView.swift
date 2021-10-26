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
                  sortDescriptors: [NSSortDescriptor(keyPath: \Meal.date, ascending: true)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    
    @StateObject var manager = ActivityManager()
    @State private var showAddMeal = false
    
    var body: some View{
        NavigationView{
            ShowView()
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        EditButton().disabled(meals.count == 0)
                        Button {
                            self.showAddMeal.toggle()
                        } label: {
                            Label("Add", systemImage: "plus")
                                .font(.title3)
                        }.buttonStyle(.bordered)
                    }
                })
                .navigationTitle(Text("Meals"))
                .sheet(isPresented: $showAddMeal) {
                    //
                } content: {
                    AddMealView()
                        .environment(\.managedObjectContext,context)
                }
            
        }.background(Color(uiColor: .systemGroupedBackground))
    }
    
    @ViewBuilder
    func ShowView() -> some View {
        if meals.count == 0 {
            VStack {
                Text("No meal is added.").bold()
            }
        } else {
            List {
                Section {
                    ForEach(meals) { meal in
                        MealCell(meal: meal)
                    }.onDelete { index in
                        self.deleteMeal(at: index)
                    }
                }footer: {
                    if meals.count == 1 {
                        Text("1 Meal").bold()
                    } else {
                        Text("\(meals.count) Meals").bold()
                    }
                    
                }
            }
        }
    }
    
    func deleteMeal(at offsets: IndexSet){
        for index in offsets{
            let item = meals[index]
            //$manager.deleteMeal(meal: item, at: context)
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

