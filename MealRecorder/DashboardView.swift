//
//  DashboardView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    
    let columns : [GridItem] = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    @StateObject var manager = ActivityManager.shared
    
    var body: some View {
        NavigationView{
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(manager.items){ item in
                        DashboardCell(item: item)
                    }
                }
                .onAppear(perform: {
                   refresh()
                })
                .padding([.leading,.trailing,.bottom])
            .navigationTitle(Text("Dashboard"))
            
        }
    }
    
    func refresh(){
        manager.getMealCount(from: meals)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview
            .container.viewContext
        return DashboardView().environment(\.managedObjectContext, previewContext)
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
