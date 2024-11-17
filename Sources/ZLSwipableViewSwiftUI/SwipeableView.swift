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


public struct SwipeableView<Content: View>: UIViewRepresentable {
    
    @ViewBuilder let content: () -> Content
    
    //  Configurable view attributes
    //
    //  This is incomplete relative to the full functionality of ZLSwipeableView.  I want to
    //  limit all this until the usage pattern of SwipeableView within SwiftUI settles down before
    //  investing a bunch of effort mapping all of ZLSwipeableView's custiomizations into SwiftUI land.
    
    private var didStart: ((_: Content) -> Void)? = nil
    private var didEnd: ((_: Content) -> Void)? = nil
    private var didCancel: ((_: Content) -> Void)? = nil
    private var numberOfActiveView: UInt?
    private var numberOfHistoryItem: UInt?
    
    public init(content: @escaping () -> Content) {
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
        var viewControllers = Set<UIHostingController<Content>>()
        
        if let numberOfActiveView = numberOfActiveView {
            newView.numberOfActiveView = numberOfActiveView
        }
        if let numberOfHistoryItem = numberOfHistoryItem {
            newView.numberOfHistoryItem = numberOfHistoryItem
        }
        
        newView.nextView = {
            guard let _ = newView.superview else { return UIView() } // Swipable view not yet part of a window and thus has no size
            
            let vc = UIHostingController(rootView: content())
            
            //  The UIHostingController documentation talks about adding it as a child to the containing
            //  view controller.  I don't know how to gain access to the containing view controller from
            //  SwiftUI.  It all seems to be working without doing this but there may be some usa pattern
            //  that fails because this was not done.
            //newView.viewController?.addChild(vc)
            
            vc.view?.frame = newView.bounds
            vc.view?.backgroundColor = .clear
            viewControllers.insert(vc)
            return vc.view
        }
        
        newView.didStart = {view, location in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                didStart?(vc.rootView)
            }
        }
        newView.swiping = {view, location, translation in
            //print("Swiping at view location: \(location) translation: \(translation)")
        }
        newView.didEnd = {view, location in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                didEnd?(vc.rootView)
            }
        }
        newView.didSwipe = {view, direction, vector in
            //print("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        newView.didCancel = {view in
            if let vc = viewControllers.first(where: { avc in
                avc.view == view
            }) {
                didCancel?(vc.rootView)
            }
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
        print("updateUIView")
    }
    
    public func onDidStart(action: @escaping (_: any View) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didStart = action
        return copiedView
    }
    
    public func onDidEnd(action: @escaping (_: any View) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didEnd = action
        return copiedView
    }
    
    public func onDidCancel(action: @escaping (_: any View) -> Void) -> Self {
        var copiedView = self
        
        copiedView.didCancel = action
        return copiedView
    }
    
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
}
