//
//  ContentView.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2024-11-15.
//

import SwiftUI
import ZLSwipeableViewSwiftUI


struct NamedColor: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let namedColors: [NamedColor] = [
    .init(name: "Green", color: .green),
    .init(name: "Blue", color: .blue),
    .init(name: "Purple", color: .purple),
    .init(name: "Pink", color: .pink),
    .init(name: "Yellow", color: .yellow),
    .init(name: "Brown", color: .brown),
    .init(name: "Teal", color: .teal),
    .init(name: "Cyan", color: .cyan),
    .init(name: "Orange", color: .orange),
    .init(name: "Red", color: .red),
    .init(name: "Mint", color: .mint),
    .init(name: "Indigo", color: .indigo),
]


struct ContentView: View {
    @State private var currentColor: NamedColor?

    var body: some View {
        VStack {
            Text(currentColor?.name ?? "Done")
                .font(.headline)
                .padding(.bottom)

            SwipeableView(namedColors, currentItem: $currentColor) { item in
                ZStack {
                    CardView()
                        .foregroundColor(item.color)
                    VStack {
                        Text(item.name)
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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
