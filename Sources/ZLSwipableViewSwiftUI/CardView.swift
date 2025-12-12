//
//  CardView.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2024-11-15.
//

import SwiftUI


public struct CardView: View {
    
    public init() {
    }
    
    public var body: some View {
        GeometryReader { g in
            let size = min(g.size.width, g.size.height)
            
            RoundedRectangle(cornerRadius: size * 0.06)
                .shadow(color: .primary.opacity(0.25), radius: 4, x: 0, y: 1.5)
        }
    }
}


#Preview {
    CardView()
        .foregroundStyle(Color.mint)
        .padding()
}
