//
//  CardView.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2024-11-15.
//

import SwiftUI


struct CardView: View {
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 1.5)
    }
}


#Preview {
    CardView(color: .mint)
        .padding()
}
