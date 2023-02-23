//
//  ViewExtensions.swift
//  MealRecorder
//
//  Created by Ege Sucu on 23.02.2023.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
