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

    var body: some View {
        SwipeableView(colors, id: \.self) { color in
            ZStack {
                CardView()
                    .foregroundColor(color)
                VStack {
                    Text("Hello World")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(5)
            .onZLSwipeStarted { location in
                print("Card.onZLSwipeStarted at \(location)...")
            }
            .onZLSwipeCancelled {
                print("Card.onZLSwipeCancelled...")
            }
        }
        .numberOfActiveView(5)
        .onZLSwiped { direction, _ in
            print("SwipeableView.onZLSwiped \(direction)...")
        }
        .onZLSwipeStarted { location in
            print("SwipeableView.onZLSwipeStarted at \(location)...")
        }
        .onZLSwipeCancelled {
            print("SwipeableView.onZLSwipeCancelled...")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
