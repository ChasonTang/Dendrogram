//
//  CompatibleShadowView.swift
//  Dendrogram
//
//  Created by 唐佳诚 on 2020/12/28.
//

import UIKit
import yoga

private func sanitizeMeasurement(_ constrainedSize: CGFloat, _ measuredSize: CGFloat, _ measureMode: YGMeasureMode) -> CGFloat {
    if measureMode == .exactly {
        return constrainedSize;
    } else if measureMode == .atMost {
        return CGFloat.minimum(constrainedSize, measuredSize)
    } else {
        return measuredSize;
    }
}

private func compatibleMeasure(_ node: YGNodeRef?, _ width: Float, _ widthMode: YGMeasureMode, _ height: Float, _ heightMode: YGMeasureMode) -> YGSize {
    let constrainedWidth = widthMode == .undefined ? CGFloat.greatestFiniteMagnitude : CGFloat(width);
    let constrainedHeight = heightMode == .undefined ? CGFloat.greatestFiniteMagnitude : CGFloat(height);

    guard let shadowViewPointer = YGNodeGetContext(node) else {
        // 返回 YGSize
        return YGSize(width: 0, height: 0)
    }
    let shadowView = Unmanaged<CompatibleShadowView>.fromOpaque(shadowViewPointer).takeUnretainedValue()
    guard let view = shadowView.view else {
        return YGSize(width: 0, height: 0)
    }
    var sizeThatFits = CGSize.zero;
    
    if !Thread.isMainThread {
        assert(false, "Is not in main thread")
        
        return YGSize(width: 0, height: 0)
    }

    // The default implementation of sizeThatFits: returns the existing size of
    // the view. That means that if we want to layout an empty UIView, which
    // already has got a frame set, its measured size should be CGSizeZero, but
    // UIKit returns the existing size.
    //
    // See https://github.com/facebook/yoga/issues/606 for more information.
    if view.isMember(of: UIView.self) || view.subviews.count > 0 {
        sizeThatFits = view.sizeThatFits(CGSize(width: constrainedWidth, height: constrainedHeight))
    }
    
    return YGSize(width: Float(sanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode)), height: Float(sanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode)))
}

private final class CompatibleShadowView: ShadowView {
    
    var view: UIView?
    
    override func dirtyLayout() {
        super.dirtyLayout()
        if !Thread.isMainThread {
            assert(false, "Is not in main thread")
            
            return
        }
        // 1. 叶节点 -> 叶节点（脏），需要 markDirty + setNeedsLayout
        // 2. 容器节点 -> 容器节点（脏），只需要 setNeedsLayout
        // 3. 叶节点 -> 容器节点（脏），只需要 setNeedsLayout
        // 4. 容器节点 -> 叶节点（脏），只需要 setNeedsLayout
        // attachNodesFromViewHierarchy 会针对 2 3 4 情况自行做出标记脏节点的动作
        if YGNodeGetChildCount(yogaNode) == 0 {
            YGNodeMarkDirty(yogaNode)
        }
    }
}
