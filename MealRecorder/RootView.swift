//
//  RootView.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI

struct RootView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        TabView{
            DashboardView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                Label("Dashboard", systemImage: "circle.grid.2x2.fill")
            }
            MealListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }
            
        }.accentColor(Color(uiColor: .label))
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}


