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
            if colorIndex <= 10 {
                ZStack {
                    CardView()
                        .foregroundColor(nextColor)
                    VStack {
                        Text("Hello World")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.white)
                        Text("\(colorIndex)")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.white)
                            .onZLSwipeStarted { location in
                                print("Text.onZLSwipeStarted at \(location)...")
                            }
                            .onZLSwipeEnded { location in
                                print("Text.onZLSwipeEnded at \(location)...")
                            }
                            .onZLSwipeCancelled {
                                print("Text.onZLSwipeCancelled...")
                            }
                    }
                }
                .padding(5)
                .onZLSwipeStarted { location in
                    print("Card.onZLSwipeStarted at \(location)...")
                }
                .onZLSwipeEnded { location in
                    print("Card.onZLSwipeEnded at \(location)...")
                }
                .onZLSwipeCancelled {
                    print("Card.onZLSwipeCancelled...")
                }
            }
            else {
                nil
            }
        }
        .numberOfActiveView(5)
        .onZLSwipeStarted { location in
            print("SwipeableView.onZLSwipeStarted at \(location)...")
        }
        .onZLSwipeEnded { location in
            print("SwipeableView.onZLSwipeEnded at \(location)...")
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
