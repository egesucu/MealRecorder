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
                    NSSortDescriptor(keyPath: \Meal.date, ascending: false)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    
    @State private var showAddMeal = false
    @State private var selection = Set<Meal>()
    @State private var isEditMode: EditMode = .inactive
    @State private var showMoreItems = false
    
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
        .onAppear(perform: {
            print(meals)
            context.refreshAllObjects()
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
                Section{
                    ForEach(meals.filter({ $0.date ?? .now >= Calendar.current.startOfDay(for: .now) })) { meal in
                        MealCell(meal: meal)
                            .padding(.bottom,10)
                    }
                    .onDelete(perform: deleteMeal)
                    
                } header: {
                    Text("Today")
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(.clear)
                Section{
                    ForEach(showMoreItems ?  meals.filter({ $0.date ?? .now < Calendar.current.startOfDay(for: .now) }) : Array(meals.filter({ $0.date ?? .now < Calendar.current.startOfDay(for: .now) }).prefix(3)) ) { meal in
                        MealCell(meal: meal)
                            .padding(.bottom,10)
                    }
                    .onDelete(perform: deleteMeal)
                    
                } header: {
                    Text("Previous")
                } footer: {
                    if meals.filter({ $0.date ?? .now < Calendar.current.startOfDay(for: .now) }).count > 3{
                        Button {
                            showMoreItems.toggle()
                        } label: {
                            HStack{
                                Text(showMoreItems ? "Show Less" : "Show More").animation(.easeInOut)
                                Image(systemName: showMoreItems ? "chevron.up.circle.fill" : "chevron.down.circle.fill").animation(.easeInOut)
                            }
                            
                        }

                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(.clear)
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

