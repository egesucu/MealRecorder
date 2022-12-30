//
//  MealList.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

enum MealFilter: String, CaseIterable{
    case all = "All"
    case thisWeek = "Weekly"
    case thisMonth = "Monthly"
}

struct MealListView: View {
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [
                    NSSortDescriptor(keyPath: \Meal.date, ascending: false)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    @State private var filteredMeals : [Meal] = []
    
    @State private var showAddMeal = false
    @State private var selection = Set<Meal>()
    @State private var isEditMode: EditMode = .inactive
    @State private var showMoreItems = false
    @State private var filter : MealFilter = .all
    
    var body: some View{
        NavigationView{
            VStack{
                ShowView()
                    .toolbar {
                        Menu(content: {
                            Picker("Destination", selection: $filter) {
                                ForEach(MealFilter.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                        }, label: {
                            Text(filter.rawValue).bold()
                            
                        })
                        .disabled(meals.count == 0)
                        EditButton()
                            .disabled(meals.count == 0)
                        
                        Button {
                            self.showAddMeal.toggle()
                        } label: {
                            Label("Add Meal", systemImage: showAddMeal ? "plus.circle.fill" : "plus.circle")
                        }
                    }
                    .navigationTitle(Text("Meals"))
            }
            .sheet(isPresented: $showAddMeal, onDismiss: {
                }, content: {
                    AddMealView()
                        .environment(\.managedObjectContext,context)
            })
            
        }
        .onAppear(perform: {
            print(meals)
            context.refreshAllObjects()
            filterMeals()
        })
        .onChange(of: filter, perform: { _ in
            filterMeals()
        })
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    func ShowView() -> some View {
        if meals.count == 0 {
            VStack {
                Text("No meal is added.").bold()
            }
        } else {
            List(selection: $selection) {
                ForEach(filteredMeals) { meal in
                    MealCell(meal: meal)
                        .padding(.bottom,10)
                }
                .onDelete(perform: deleteMeal)
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(.clear)
            }.refreshable(action: {
                context.refreshAllObjects()
                filterMeals()
            })
            
            .listStyle(.insetGrouped)
        }
    }
    
    func filterMeals(){
        
        switch filter {
        case .all:
            filteredMeals = meals
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisWeek:
            filteredMeals = meals
                .filter({ $0.date ?? .now >= Calendar.current.startOfDay(for: .now).addingTimeInterval(60 * 60 * 24 * 7 * -1) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        case .thisMonth:
            filteredMeals = meals
                .filter({ $0.date ?? .now >= Calendar.current.startOfDay(for: .now).addingTimeInterval(60 * 60 * 24 * 30 * -1) })
                .sorted(by: { $0.date ?? .now > $1.date ?? .now })
        }
    }
    

    func deleteMeal(at offsets: IndexSet){
        for offset in offsets{
            context.delete(meals[offset])
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

