//
//  ContentView.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2024-11-15.
//

import SwiftUI
import ZLSwipeableViewSwiftUI


struct ContentView: View {
    let colors: [Color] = [.green,
                           .blue,
                           .purple,
                           .pink,
                           .yellow,
                           .brown,
                           .teal,
                           .cyan,
                           .orange,
                           .red,
                           .mint,
                           .indigo]
    @State var colorIndex = 0

    var nextColor: Color {
        let c = colors[colorIndex % colors.count]
                      
        colorIndex += 1
        return c
    }
    
    var body: some View {
        SwipeableView() {
            ZStack {
                CardView(color: nextColor)
                VStack {
                    Text("Hello World")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.white)
                    Text("\(colorIndex)")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .numberOfActiveView(5)
        .onDidStart { _ in
            print("SwiftUI Did Start...")
        }
        .onDidEnd { _ in
            print("SwiftUI Did End...")
        }
        .onDidCancel { _ in
            print("SwiftUI Did Cancel...")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
