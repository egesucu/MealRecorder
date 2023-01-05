//
//  MealList.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

enum MealFilter: String, CaseIterable{
    case all = "All"
    case today = "Today"
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
    
    let mealDataManager = MealDataManager.shared
    
    var body: some View{
        NavigationView{
            ZStack(alignment: .bottom){
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
                        }
                        .navigationTitle(Text("Meals"))
                }
                Button {
                    showAddMeal.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                }
                .contentShape(Circle())

            }
            .sheet(isPresented: $showAddMeal, onDismiss: {
                filterMeals()
                }, content: {
                    AddMealView(mealDataManager: mealDataManager)
                        .environment(\.managedObjectContext,context)
            })
            
        }
        .onAppear(perform: {
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
        if filteredMeals.count == 0 {
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
            }
            .listStyle(.insetGrouped)
            .refreshable {
                context.refreshAllObjects()
                filterMeals()
            }
            
        }
    }
    
    func filterMeals(){
        filteredMeals = mealDataManager.filterMeals(meals: meals, filter: filter)
    }
    

    func deleteMeal(at offsets: IndexSet){
        mealDataManager.deleteMeal(context: context, meals: filteredMeals, at: offsets)
        filterMeals()
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        MealListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

