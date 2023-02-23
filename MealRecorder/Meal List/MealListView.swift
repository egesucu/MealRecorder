//
//  MealList.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

struct MealListView: View {

    @Environment(\.managedObjectContext) var context
    @StateObject var mealViewModel = MealListViewModel()
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [.init(keyPath: \Meal.date, ascending: false)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                ZStack(alignment: .bottom) {
                    showView()
                    addButton()
                }
            }
            .navigationTitle(Text("Meals"))

        }
        .onAppear {
            mealViewModel.filterMeals(meals: meals)
        }
        .onChange(of: mealViewModel.filter ) { _ in
            mealViewModel.filterMeals(meals: meals)
        }
        .toolbar(content: bottomToolbar)

        .sheet(isPresented: $mealViewModel.showAddMeal, onDismiss: {
            context.refreshAllObjects()
            mealViewModel.filterMeals(meals: meals)
            }, content: {
                AddMealView(mealViewModel: mealViewModel)
                    .environment(\.managedObjectContext, context)
        })
    }
}

// MARK: - View Builders
extension MealListView {
    @ViewBuilder
    func addButton() -> some View {
        VStack {
            Spacer()
            Button {
                mealViewModel.showAddMeal.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(.systemGroupedBackground), .orange)
            }
        }
    }

    @ViewBuilder
    func showView() -> some View {
        VStack {
            if mealViewModel.filteredMeals.isEmpty {
                VStack {
                    Spacer()
                    Text("No meal is added.")
                        .bold()
                    Spacer()
                }
            } else {
                List(selection: $mealViewModel.selection) {
                    ForEach(mealViewModel.filteredMeals, id: \.id) { meal in
                        MealCell(meal: meal)
                            .padding(.bottom, 10)
                    }
                    .onDelete(perform: deleteMeal(at:))
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(.clear)
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    context.refreshAllObjects()
                    mealViewModel.filterMeals(meals: meals)
                }

            }
        }
    }

    func deleteMeal(at offsets: IndexSet) {
        for offset in offsets {
            context.delete(meals[offset])
        }
        PersistenceController.save(context: context)
    }

    @ToolbarContentBuilder
    func bottomToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu(content: {
                Picker("Destination", selection: $mealViewModel.filter) {
                    ForEach(MealFilter.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }, label: {
                Text(mealViewModel.filter.rawValue)
                    .bold()

            })
            .disabled(mealViewModel.filteredMeals.isEmpty)

            EditButton()
                .disabled(mealViewModel.filteredMeals.isEmpty)
        }
    }
}

struct MealList_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return MealListView()
            .environment(\.managedObjectContext, context)
    }
}
