//
//  DashboardView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 16.10.2021.
//

import SwiftUI

struct DashboardView: View {
    
    var columns : [GridItem] = [GridItem(.adaptive(minimum: 100, maximum: 200))]
    
    var items : [DashItem] = [
        DashItem(title: "Exercise", detail: "", type: .exercise, color: .green),
        DashItem(title: "Water", detail: "", type: .water, color: .blue),
        DashItem(title: "Steps", detail: "", type: .steps, color: .orange),
        DashItem(title: "Meal", detail: "", type: .meals, color: .yellow)
    ]
    
    var body: some View {
        NavigationView{
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items){ item in
                    RoundedDashView(item: item)
                }
                
            }
            .padding()
            .navigationTitle(Text("Dashboard"))
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
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
    case water,exercise,meals,steps
}
