//
//  DashboardView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    
    let columns : [GridItem] = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Meal.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Meal.date, ascending: true)],
                  animation: .easeInOut)
    var meals: FetchedResults<Meal>
    @StateObject var manager = ActivityManager()
    
    var body: some View {
        NavigationView{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(manager.items){ item in
                            DashboardCell(item: item)
                        }
                    }
                    .onAppear(perform: {
                        manager.fetchData(meals: meals)
                    })
                    .padding([.leading,.trailing,.bottom])
                .navigationTitle(Text("Dashboard"))
            }
            
        }.navigationViewStyle(.stack)
=======
                }.refreshable {
                    self.refresh()
                }
                .onAppear(perform: {
                    self.refresh()
                })
                .padding([.leading,.trailing,.bottom])
                .navigationTitle(Text("Dashboard"))
            }
            
        }
    }
    
    func refresh(){
        manager.accessHealthData()
        manager.fetchData()
        manager.getMealCount(from: meals)
>>>>>>> main
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
