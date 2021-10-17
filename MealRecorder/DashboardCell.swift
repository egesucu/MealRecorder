//
//  DashboardCell.swift
//  MealRecorder
//
//  Created by Ege Sucu on 17.10.2021.
//

import SwiftUI


struct DashboardCell: View{
    
    var item: DashItem
    
    var body: some View{
        
        ZStack(alignment: .topTrailing) {
            ZStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.color)
                    .contrast(0.6)
                    .shadow(radius: 8)
                VStack{
                    Text(item.title).font(.title2).padding(.top)
                    Spacer()
                    Text(item.detail).font(.title3).bold()
                }
                .foregroundColor(.white)
                .padding()
            }
            
            Image(systemName: "drop.fill")
                .foregroundColor(.white)
                .offset(x: -5, y: 5)
        }.padding()
        
    }
    
}


struct DashboardCellPreview : PreviewProvider{
    
    static var previews: some View{
        DashboardCell(item: DashItem(title: "Water", detail: "2.000 ml", type: .water, color: .blue))
            .frame(width: 200, height: 200, alignment: .center)
            .previewLayout(.sizeThatFits)
    }
}
