//
//  ZLSwipeableView.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2024-11-15.
//

import SwiftUI
import UIKit
import ZLSwipeableViewSwift


private class SwiftUIZLSwipeableView: ZLSwipeableView {
    
    //  UIViewRepresentable invokes it's makeUIView method before the parent view is placed into
    //  a container view and window.  This means that the frame size is unknown.  Only when
    //  didMoveToWindow is called can we properly size the card views.
    
    override func didMoveToWindow() {
        if superview != nil {
            discardViews()
            loadViews()
        }
    }
}


class SwipableUIHostringController<Content>: UIHostingController<Content> where Content : View {
    fileprivate var swipeCoordinator: SwipeableViewCoordinator
    
    fileprivate init(swipeCoordinator: SwipeableViewCoordinator, rootView: Content) {
        self.swipeCoordinator = swipeCoordinator
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct SwipeableView<Content: View>: UIViewRepresentable {
    
    @ViewBuilder let content: () -> Content?
    
    //  Configurable view attributes
    //
    //  This is incomplete relative to the full functionality of ZLSwipeableView.  I want to
    //  limit all this until the usage pattern of SwipeableView within SwiftUI settles down before
    //  investing a bunch of effort mapping all of ZLSwipeableView's custiomizations into SwiftUI land.
    
    private var didStart: ((_ location: CGPoint) -> Void)? = nil
    private var isSwiping: ((_ location: CGPoint, _ translation: CGPoint, _ movement: UnitPoint) -> Void)? = nil
    private var didEnd: ((_ location: CGPoint) -> Void)? = nil
    private var didSwipe: ((_ direction: Direction, _ velocity: CGVector) -> Void)? = nil
    private var didCancel: (() -> Void)? = nil
    private var numberOfActiveView: UInt?
    private var numberOfHistoryItem: UInt?
    
    public init(content: @escaping () -> Content?) {
        self.content = content
    }
    
    //  TODO: It seems to me that SwipableView should probably follow the API pattern established for
    //  SwiftUI Lists.  This means supporting ForEach and/or allowing array's of data to be passed to
    //  the initializer to facilite passing of data into the content creation code.
    //
    //  Eg 1:
    //
    //  @State currentCard: String
    //
    //  var body: some View {
    //      let names = ["Mark", "Janet", "Marleen", "Keith", "Frank"]
    //
    //      SwipableView(currentCard: $currentCard) {
    //          ForEach(names, \.self) { name in
    //              ZStack {
    //                  CardView(color: ...)
    //                  Text(name)
    //              }
    //          }
    //      }
    //  }
    //
    //  This approach implies a bounded sequence of cards.  The existing implementation provides an
    //  unbounded sequence of cards.
    //
    //  I'll return to this once I have more experience with SwipeableView and I can find some good
    //  examples of the correct way to implement something like SwiftUI's List.
    //
    
    public func makeUIView(context: Context) -> ZLSwipeableView {
        let newView = SwiftUIZLSwipeableView()
        var viewControllers = Set<SwipableUIHostringController<AnyView>>()
        
        if let numberOfActiveView = numberOfActiveView {
            newView.numberOfActiveView = numberOfActiveView
        }
        if let numberOfHistoryItem = numberOfHistoryItem {
            newView.numberOfHistoryItem = numberOfHistoryItem
        }
        
        newView.nextView = {
            guard let _ = newView.superview else { return nil } // Swipable view not yet part of a window and thus has no size
            guard let rootView = content() else { return nil } // last card?

            let swipeCoordinator = SwipeableViewCoordinator()
            let vc = SwipableUIHostringController(swipeCoordinator: swipeCoordinator,
                                                  rootView: AnyView(rootView.environmentObject(swipeCoordinator)))
            
            //  The UIHostingController documentation talks about adding it as a child to the containing
            //  view controller.  I don't know how to gain access to the containing view controller from
            //  SwiftUI.  It all seems to be working without doing this but there may be some us pattern
            //  that fails because this was not done.
            //newView.viewController?.addChild(vc)
            
            vc.view?.frame = newView.bounds
            vc.view?.backgroundColor = .clear
            viewControllers.insert(vc)
            return vc.view
        }
        
        newView.didStart = { view, location in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                vc.swipeCoordinator.swipeStartedTransition = .init(location: location)
            }
            didStart?(location)
        }
        newView.swiping = { view, location, translation in
            let halfWidth = view.frame.size.width / 2
            let halfHeight = view.frame.size.height / 2
            let movement = UnitPoint(x: min(max(translation.x / halfWidth, -1), 1),
                                     y: min(max(translation.y / halfHeight, -1), 1))

            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                vc.swipeCoordinator.swipingTransition = .init(location: location, translation: translation, movement: movement)
            }
            isSwiping?(location, translation, movement)
        }
        newView.didSwipe = { view, direction, velocity in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                vc.swipeCoordinator.swipedTransition = .init(direction: direction, velocity: velocity)
            }
            didSwipe?(direction, velocity)
        }
        newView.didEnd = { view, location in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                vc.swipeCoordinator.swipeEndedTransition = .init(location: location)
            }
            didEnd?(location)
        }
        newView.didCancel = { view in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                vc.swipeCoordinator.swipeCancelledTransition += 1
            }
            didCancel?()
        }
        newView.didDisappear = { view in
            //print("Did disappear")
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                viewControllers.remove(vc)
            }
        }
        
        return newView

    }
    
    public func updateUIView(_ uiView: ZLSwipeableView, context: Context) {
        #if DEBUG
        print("updateUIView")
        #endif
    }
    
    //  Modifiers - Container View Callbacks
    public func onZLSwipeStarted(action: @escaping (_ location: CGPoint) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didStart = action
        return copiedView
    }
    
    public func onZLSwipeCancelled(action: @escaping () -> Void) -> Self {
        var copiedView = self
        
        copiedView.didCancel = action
        return copiedView
    }

    public func onZLSwipeEnded(action: @escaping (_ location: CGPoint) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didEnd = action
        return copiedView
    }

    public func onZLSwiped(action: @escaping (_ direction: Direction, _ velocity: CGVector) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didSwipe = action
        return copiedView
    }
    
    public func onZLSwiping(action: @escaping (_ location: CGPoint, _ translation: CGPoint, _ movement: UnitPoint) -> Void) -> Self {
        var copiedView = self
        
        copiedView.isSwiping = action
        return copiedView
    }

    //  Modifiers - Configuration
    public func numberOfActiveView(_ newValue: UInt) -> Self {
        var copiedView = self
        
        copiedView.numberOfActiveView = newValue
        return copiedView
    }
    
    public func numberOfHistoryItem(_ newValue: UInt) -> Self {
        var copiedView = self
        
        copiedView.numberOfHistoryItem = newValue
        return copiedView
    }
    
    //  Modifiers - Move to new API please!
    @available(*, deprecated, renamed: "onZLSwipeStarted")
    public func onDidStart(action: @escaping (_ location: CGPoint) -> Void) -> Self {
        return onZLSwipeStarted(action: action)
    }
        
    @available(*, deprecated, renamed: "onZLSwipeEnded")
    public func onDidEnd(action: @escaping (_ location: CGPoint) -> Void) -> Self {
        return onZLSwipeEnded(action: action)
    }
    
    @available(*, deprecated, renamed: "onZLSwipeCancelled")
    public func onDidCancel(action: @escaping () -> Void) -> Self {
        return onZLSwipeCancelled(action: action)
    }
}


internal final class SwipeableViewCoordinator: ObservableObject {
    struct SwipingData: Equatable {
        let location: CGPoint
        let translation: CGPoint
        let movement: UnitPoint
    }
    
    struct SwipedData: Equatable {
        let direction: Direction
        let velocity: CGVector
    }
    
    struct StartedData: Equatable {
        let location: CGPoint
    }
    
    struct EndedData: Equatable {
        let location: CGPoint
    }

    @Published internal var swipingTransition: SwipingData? = nil
    @Published internal var swipedTransition: SwipedData? = nil
    @Published internal var swipeStartedTransition: StartedData? = nil
    @Published internal var swipeEndedTransition: EndedData? = nil
    @Published internal var swipeCancelledTransition = 0
}


struct ZLSwipingReceiverModifier: ViewModifier {
    // This is passed into the environment by the UIHostingController setup
    @EnvironmentObject fileprivate var coordinator: SwipeableViewCoordinator
    
    fileprivate var onSwiping: ((_ location: CGPoint, _ translation: CGPoint, _ movement: UnitPoint) -> Void)?

    func body(content: Content) -> some View {
        content
            // Observe the on-going translation changes
            .onChange(of: coordinator.swipingTransition) {
                if let swipingTransition = coordinator.swipingTransition {
                    onSwiping?(swipingTransition.location, swipingTransition.translation, swipingTransition.movement)
                    //coordinator.swipingTransition = nil
                }
            }
    }
}


struct ZLSwipedReceiverModifier: ViewModifier {
    // This is passed into the environment by the UIHostingController setup
    @EnvironmentObject fileprivate var coordinator: SwipeableViewCoordinator
    
    fileprivate var onSwiped: ((_ direction: Direction, _ velocity: CGVector) -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: coordinator.swipedTransition) {
                if let swipedTransition = coordinator.swipedTransition {
                    onSwiped?(swipedTransition.direction, swipedTransition.velocity)
                    //coordinator.swipedTransition = nil
                }
            }
    }
}


internal struct ZLSwipeCancelledReceiverModifier: ViewModifier {
    // This is passed into the environment by the UIHostingController setup
    @EnvironmentObject fileprivate var coordinator: SwipeableViewCoordinator
    
    fileprivate var onSwipeCancelled: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: coordinator.swipeCancelledTransition) {
                //if let _ = coordinator.swipeCancelledTransition {
                    onSwipeCancelled?()
                    //coordinator.swipeCancelledTransition = nil
                //}
            }
    }
}


internal struct ZLSwipeStartedReceiverModifier: ViewModifier {
    // This is passed into the environment by the UIHostingController setup
    @EnvironmentObject fileprivate var coordinator: SwipeableViewCoordinator
    
    fileprivate var onSwipeStarted: ((_ location: CGPoint) -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: coordinator.swipeStartedTransition) {
                if let startedTransition = coordinator.swipeStartedTransition {
                    onSwipeStarted?(startedTransition.location)
                    //coordinator.swipeStartedTransition = nil
                }
            }
    }
}


internal struct ZLSwipeEndedReceiverModifier: ViewModifier {
    // This is passed into the environment by the UIHostingController setup
    @EnvironmentObject fileprivate var coordinator: SwipeableViewCoordinator
    
    fileprivate var onSwipeEnded: ((_ location: CGPoint) -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: coordinator.swipeEndedTransition) {
                if let endedTransition = coordinator.swipeEndedTransition {
                    onSwipeEnded?(endedTransition.location)
                    //coordinator.swipeEndedTransition = nil
                }
            }
    }
}


extension View {
    public func onZLSwiping(perform action: @escaping (_ location: CGPoint, _ translation: CGPoint, _ movement: UnitPoint) -> Void) -> some View {
        self.modifier(ZLSwipingReceiverModifier(onSwiping: action))
    }
    
    public func onZLSwiped(perform action: @escaping (_ direction: Direction, _ velocity: CGVector) -> Void) -> some View {
        self.modifier(ZLSwipedReceiverModifier(onSwiped: action))
    }

    public func onZLSwipeCancelled(perform action: @escaping () -> Void) -> some View {
        self.modifier(ZLSwipeCancelledReceiverModifier(onSwipeCancelled: action))
    }

    public func onZLSwipeStarted(perform action: @escaping (_ location: CGPoint) -> Void) -> some View {
        self.modifier(ZLSwipeStartedReceiverModifier(onSwipeStarted: action))
    }
    
    public func onZLSwipeEnded(perform action: @escaping (_ location: CGPoint) -> Void) -> some View {
        self.modifier(ZLSwipeEndedReceiverModifier(onSwipeEnded: action))
    }

}
