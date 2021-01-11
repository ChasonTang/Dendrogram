//
//  LayoutManager.swift
//  Dendrogram
//
//  Created by 唐佳诚 on 2020/12/28.
//

import Foundation
import yoga
import UIKit

private let layoutManager = LayoutManager()

//private enum LayoutEngineMode {
//    case normal
//    case compatible
//}

//private var layoutEngineMode = LayoutEngineMode.compatible

private struct DimensionFlexibility: OptionSet {

    let rawValue: UInt
    
    static let none = DimensionFlexibility([])

    static let width = DimensionFlexibility(rawValue: 1 << 0)

    static let height = DimensionFlexibility(rawValue: 1 << 1)
}

private var ShadowViewKey: UInt8 = 0

extension UIView {

    var dmShadowView: ShadowView {
        get {
            let shadowViewOrNil = objc_getAssociatedObject(self, &ShadowViewKey) as? ShadowView
            guard let shadowView = shadowViewOrNil else {
                let shadowView = CompatibleShadowView(view: self)
                objc_setAssociatedObject(self, &ShadowViewKey, shadowView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return shadowView
            }

            return shadowView
        }
    }

    var isDMLayoutEnabled: Bool {
        get {
            objc_getAssociatedObject(self, &ShadowViewKey) as? ShadowView != nil
        }
    }
}

private func getFrame(view: UIView) -> CGRect {
    CGRect(x: view.center.x - view.bounds.size.width / 2, y: view.center.y - view.bounds.size.height / 2, width: view.bounds.size.width, height: view.bounds.size.height)
}

private func setFrame(view: UIView, frame: CGRect) {
    // These frames are in terms of anchorPoint = topLeft, but internally the
    // views are anchorPoint = center for easier scale and rotation animations.
    // Convert the frame so it works with anchorPoint = center.
    let position = CGPoint(x: frame.minX, y: frame.minY)
    let bounds = CGRect(origin: .zero, size: frame.size)

    // Avoid crashes due to nan coords
    if position.x.isNaN || position.y.isNaN || bounds.origin.x.isNaN || bounds.origin.y.isNaN || bounds.size.width.isNaN || bounds.size.height.isNaN {
        // TODO(唐佳诚): log Error
//        print("Invalid layout for \(view). position: \(position). bounds: \(bounds)")
        return
    }

    view.center = position
    view.bounds = bounds
}

private struct LayoutManager {

    private func applyLayout(preserveOrigin: Bool, dimensionFlexibility: DimensionFlexibility, view: UIView, affectedShadowViews: NSHashTable<ShadowView> = NSHashTable.weakObjects()) {
        guard view.isDMLayoutEnabled else {
            return
        }
        attachNodesFromViewHierarchy(shadowView: view.dmShadowView)
        let shadowView = view.dmShadowView
        var rootShadowView = RootShadowView(shadowView: shadowView)

        // 以 YGNodeRef 当前 minimumSize 为准
        let oldMinimumSize = CGSize(width: CoreGraphicsFloatFromYogaValue(YGNodeStyleGetMinWidth(shadowView.yogaNode), 0), height: CoreGraphicsFloatFromYogaValue(YGNodeStyleGetMinHeight(shadowView.yogaNode), 0))
        if oldMinimumSize != rootShadowView.minimumSize {
            rootShadowView.minimumSize = oldMinimumSize;
        }
        rootShadowView.availableSize = view.bounds.size
        if dimensionFlexibility.contains(.width) {
            rootShadowView.availableSize.width = .greatestFiniteMagnitude
        }
        if dimensionFlexibility.contains(.height) {
            rootShadowView.availableSize.height = .greatestFiniteMagnitude
        }
        rootShadowView.layout(affectedShadowViews: affectedShadowViews)
        if affectedShadowViews.count == 0 {
            // no frame change results in no UI update block
            return
        }
        let objectEnumerator = affectedShadowViews.objectEnumerator()
        while let shadowView = objectEnumerator.nextObject() as? CompatibleShadowView {
            guard let layoutMetrics = shadowView.layoutMetrics else {
                continue
            }
            let inlineView = shadowView.view

            let closure: () -> Void = {
                var frame = layoutMetrics.frame
                let isHidden = layoutMetrics.displayType == .none;
                if inlineView.isHidden != isHidden {
                    inlineView.isHidden = isHidden;
                }
                if view == inlineView && preserveOrigin {
                    let oldFrame = getFrame(view: inlineView)
                    frame.origin.x += oldFrame.origin.x
                    frame.origin.y += oldFrame.origin.y
                }
                setFrame(view: inlineView, frame: frame)
            }

            if Thread.isMainThread {
                closure()
            } else {
                DispatchQueue.main.async(execute: closure)
            }
        }
    }

    private func attachNodesFromViewHierarchy(shadowView: ShadowView) {
        guard let compatibleShadowView = shadowView as? CompatibleShadowView else {
            return
        }
        // Only leaf nodes should have a measure function
        let node = compatibleShadowView.yogaNode
        if compatibleShadowView.isLeaf {
            YGNodeRemoveAllChildren(node)
            YGNodeSetMeasureFunc(node, compatibleMeasure)
        } else {
            YGNodeSetMeasureFunc(node, nil)
        }
        var subviewsToInclude = compatibleShadowView.view.subviews.count > 0 ? Array<ShadowView>() : nil
        for view in compatibleShadowView.view.subviews {
            // 判断是否包含 ShadowView，添加到 subviewsToInclude 数组中
            if (view.isDMLayoutEnabled) {
                subviewsToInclude?.append(view.dmShadowView)
            }
        }
        if !compatibleShadowView.hasExactSameChildren(children: subviewsToInclude) {
            YGNodeRemoveAllChildren(compatibleShadowView.yogaNode)
            if let subviewsToInclude = subviewsToInclude {
                for shadowView in subviewsToInclude {
                    shadowView.superview?.removeSubview(shadowView)
                    compatibleShadowView.insertSubview(shadowView, at: Int(YGNodeGetChildCount(compatibleShadowView.yogaNode)))
                    // 深度优先
                    attachNodesFromViewHierarchy(shadowView: shadowView)
                }
            }
        }
    }
}
