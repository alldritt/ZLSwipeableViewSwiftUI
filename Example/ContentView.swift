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
    @State private var colors: [NamedColor] = Array(namedColors.prefix(3))

    var body: some View {
        SwipeableViewReader { proxy in
            VStack {
                Text(currentColor?.name ?? "No More Cards")
                    .font(.headline)
                    .padding(.bottom)

                SwipeableView(colors, currentItem: $currentColor) { item in
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
                .numberOfHistoryItem(3)
                .onZLSwiped { direction, _ in
                    print("SwipeableView.onZLSwiped \(direction)...")
                }
                .onZLSwipeStarted { location in
                    print("SwipeableView.onZLSwipeStarted at \(location)...")
                }
                .onZLSwipeCancelled {
                    print("SwipeableView.onZLSwipeCancelled...")
                }

                HStack {
                    Spacer()
                    Button("Undo") { proxy.rewind() }
                        .disabled(!proxy.canRewind)
                    Button("← Left") { proxy.swipe(.Left) }
                        .disabled(!proxy.canSwipe)
                    Button("Right →") { proxy.swipe(.Right) }
                        .disabled(!proxy.canSwipe)
                    Button("Skip") { proxy.discardTop() }
                        .disabled(!proxy.canSwipe)
                    Spacer()
                    Button("+ More") {
                        let next = namedColors.dropFirst(colors.count).prefix(3)
                        colors.append(contentsOf: next)
                    }
                    .disabled(colors.count >= namedColors.count)
                    Spacer()
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
