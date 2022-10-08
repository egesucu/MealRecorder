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
                        filterMeals()
                    }, content: {
                        AddMealView()
                            .environment(\.managedObjectContext,context)
                })
                .offset(x: -15, y: -15)
            }
            
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: filterMeals)
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
                    ForEach(previousMeals) { meal in
                        MealCell(meal: meal)
                    }.onDelete { index in
                        self.deleteMeal(mealList: previousMeals, at: index)
                    }
                } header: {
                    Text("Previous Meals")
                }
                Section{
                    ForEach(currentMeals) { meal in
                        MealCell(meal: meal)
                    }.onDelete { index in
                        self.deleteMeal(mealList: currentMeals, at: index)
                    }
                } header: {
                    Text("Today")
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    func filterMeals(){
        let todayBegin = Calendar.current.startOfDay(for: .now)
        previousMeals = meals.filter({ meal in
            return (meal.date ?? .now) < todayBegin
        })
        currentMeals = meals.filter({ meal in
            return Calendar.current.isDateInToday((meal.date ?? .now))
        })
    }
    
    func deleteMeal(mealList: [Meal], at offsets: IndexSet){
        for index in offsets{
            let item = mealList[index]
            context.delete(item)
            PersistenceController.save(context: context)
            filterMeals()
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

