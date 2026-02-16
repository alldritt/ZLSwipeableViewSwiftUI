//
//  SwipeableViewReader.swift
//  ZLSwipeableViewSwiftUI
//
//  Created by Mark Alldritt on 2025-02-16.
//

import SwiftUI
import ZLSwipeableViewSwift


// MARK: - SwipeableViewProxy

/// An imperative handle for programmatically controlling a ``SwipeableView``.
///
/// Obtain an instance through ``SwipeableViewReader``, which follows the
/// same pattern as SwiftUI's `ScrollViewReader` / `ScrollViewProxy`.
@MainActor
public final class SwipeableViewProxy {
    internal weak var zlSwipeableView: ZLSwipeableView?
    internal var onRewindIndexUpdate: (() -> Void)?
    internal var onDiscardTopIndexUpdate: (() -> Void)?

    internal init() {}

    /// Programmatically swipe the top card in the given direction with an
    /// animated transition. The regular `didSwipe` callback fires, so
    /// `currentItem` stays in sync automatically.
    public func swipe(_ direction: Direction) {
        zlSwipeableView?.swipeTopView(inDirection: direction)
    }

    /// Restore the most recently swiped card from history.
    /// This is a no-op when history is empty. Note that cards removed
    /// via ``discardTop()`` are not added to history and cannot be rewound.
    public func rewind() {
        guard let zlSwipeableView, !zlSwipeableView.history.isEmpty else { return }
        zlSwipeableView.rewind()
        onRewindIndexUpdate?()
    }

    /// Instantly remove the top card without animation.
    /// This is a no-op when there are no cards.
    public func discardTop() {
        zlSwipeableView?.discardTopCard()
        onDiscardTopIndexUpdate?()
    }

    /// Whether there are cards in history that can be rewound.
    public var canRewind: Bool {
        guard let zlSwipeableView else { return false }
        return !zlSwipeableView.history.isEmpty
    }

    /// Whether there is a top card that can be swiped or discarded.
    public var canSwipe: Bool {
        return zlSwipeableView?.topView() != nil
    }
}


// MARK: - Environment Key

private struct SwipeableViewProxyKey: EnvironmentKey {
    static let defaultValue: SwipeableViewProxy? = nil
}

extension EnvironmentValues {
    var swipeableViewProxy: SwipeableViewProxy? {
        get { self[SwipeableViewProxyKey.self] }
        set { self[SwipeableViewProxyKey.self] = newValue }
    }
}


// MARK: - SwipeableViewReader

/// A container view that provides a ``SwipeableViewProxy`` for
/// programmatic control of a ``SwipeableView``.
///
/// Usage follows the `ScrollViewReader` pattern:
///
/// ```swift
/// SwipeableViewReader { proxy in
///     VStack {
///         SwipeableView(items) { item in
///             CardView()
///         }
///         Button("Swipe Left") { proxy.swipe(.Left) }
///     }
/// }
/// ```
public struct SwipeableViewReader<Content: View>: View {
    @State private var proxy = SwipeableViewProxy()
    let content: (SwipeableViewProxy) -> Content

    public init(@ViewBuilder content: @escaping (SwipeableViewProxy) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(proxy)
            .environment(\.swipeableViewProxy, proxy)
    }
}
