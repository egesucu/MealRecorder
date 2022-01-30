//
//  DashboardView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    
    @FetchRequest(entity: Meal.entity(),sortDescriptors: [])
    var meals: FetchedResults<Meal>
    @Environment(\.managedObjectContext) var viewContext
    let columns = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    @StateObject var manager = HealthStore()
    
    var body: some View {
        NavigationView{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(manager.items){ item in
                        DashboardCell(item: item)
                    }
                }
                .padding([.leading,.trailing,.bottom])
                .navigationTitle(Text("Dashboard"))
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        reloadData()
                    } label: {
                        Image(systemName: "gobackward")
                            .font(.title2)
                    }

                }
            })
        }
        .onAppear(perform: reloadData)
        .onChange(of: manager.waterValue, perform: { _ in
            reloadData()
        })
        .navigationViewStyle(.stack)
        
    }
    
    func reloadData(){
        manager.meals = meals
        manager.loadData()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview
            .container.viewContext
        return DashboardView()
            .environment(\.managedObjectContext, previewContext)
    }
}

struct RoundedDashView: View {
    var item: DashItem
    
    var body: some View{
        VStack{
            Text("Demo")
        }
    }
}

struct DashItem: Identifiable {
    var id = UUID()
    var title : String
    var detail: String
    var type: DashType
    var color : Color
}

enum DashType {
    case water,exercise,meals,steps,calorie
}
