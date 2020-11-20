//
//  ShadowView.swift
//  Dendrogram
//
//  Created by 唐佳诚 on 2020/11/14.
//

import Foundation
import yoga

// lazy
fileprivate let screenScale = UIScreen.main.scale

fileprivate let globalYogaConfig = YGConfigNew()

fileprivate func YGNodeFreeRecursiveNew(root: YGNodeRef) {
    var skipped: UInt32 = 0
    while YGNodeGetChildCount(root) > skipped {
        let childOrNil = YGNodeGetChild(root, skipped)
        guard let child = childOrNil else {
            continue
        }
        // 下面的 if 判断只会走一条分支，因为 cloneIfNeeded 是全克隆或者不克隆
        if YGNodeGetOwner(child) != root {
            skipped += 1
        } else {
            // 早期 Yoga YGNodeRemoveChild 会触发 clone，但是由于前面注释的原因，调用 remove 实际上不会触发 clone
            YGNodeRemoveChild(root, child)
            YGNodeFreeRecursiveNew(root: child)
        }
    }
    // 剩下的都是指向原 owner 的 child，YGNodeFree 会破坏它们，因此需要先 removeAll，removeAll 方法取丢一个 child 判断是否其 owner 是自身，由于剩下都是 weak 指向的 child，因此直接会 reset vector
    YGNodeRemoveAllChildren(root)
    YGNodeFree(root)
}

fileprivate func ShadowViewMeasure(_ node: YGNodeRef?, _ width: Float, _ widthMode: YGMeasureMode, _ height: Float, _ heightMode: YGMeasureMode) -> YGSize {
    var result: YGSize = YGSize()

    guard let shadowViewPointer = YGNodeGetContext(node) else {
        return result
    }
    let shadowView = Unmanaged<ShadowView>.fromOpaque(shadowViewPointer).takeUnretainedValue()

    var intrinsicContentSize = shadowView.intrinsicContentSize
    // Replace `UIViewNoIntrinsicMetric` (which equals `-1`) with zero.
    intrinsicContentSize.width = max(0, intrinsicContentSize.width)
    intrinsicContentSize.height = max(0, intrinsicContentSize.height)

    switch widthMode {
    case .undefined:
        result.width = Float(intrinsicContentSize.width)
    case .exactly:
        result.width = width
    case .atMost:
        result.width = min(width, Float(intrinsicContentSize.width))
    @unknown default:
        return result
    }

    switch heightMode {
    case .undefined:
        result.height = Float(intrinsicContentSize.height)
    case .exactly:
        result.height = height
    case .atMost:
        result.height = min(height, Float(intrinsicContentSize.height))
    @unknown default:
        return result
    }

    return result
}

final class ShadowView {

    private let yogaNode: YGNodeRef?

    private var layoutMetrics: LayoutMetrics?;

    /**
     * Position and dimensions.
     * Defaults to { 0, 0, NAN, NAN }.
     */
    private var top: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .top)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .top, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .top, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .top, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var left: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .left)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .left, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .left, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .left, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var bottom: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .bottom)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .bottom, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .bottom, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .bottom, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var right: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .right)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .right, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .right, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .right, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var start: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .start)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .start, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .start, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .start, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var end: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, .end)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPosition(yogaNode, .end, Float.nan)
            case .point: YGNodeStyleSetPosition(yogaNode, .end, newValue.value)
            case .percent: YGNodeStyleSetPositionPercent(yogaNode, .end, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    private var width: YGValue {
        get {
            YGNodeStyleGetWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetWidthAuto(yogaNode)
            case .undefined: YGNodeStyleSetWidth(yogaNode, Float.nan)
            case .point: YGNodeStyleSetWidth(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetWidthPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var height: YGValue {
        get {
            YGNodeStyleGetHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetHeightAuto(yogaNode)
            case .undefined: YGNodeStyleSetHeight(yogaNode, Float.nan)
            case .point: YGNodeStyleSetHeight(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetHeightPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    private var minWidth: YGValue {
        get {
            YGNodeStyleGetMinWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetMinWidth(yogaNode, Float.nan)
            case .point: YGNodeStyleSetMinWidth(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetMinWidthPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var maxWidth: YGValue {
        get {
            YGNodeStyleGetMaxWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetMaxWidth(yogaNode, Float.nan)
            case .point: YGNodeStyleSetMaxWidth(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetMaxWidthPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var minHeight: YGValue {
        get {
            YGNodeStyleGetMinHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetMinHeight(yogaNode, Float.nan)
            case .point: YGNodeStyleSetMinHeight(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetMinHeightPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var maxHeight: YGValue {
        get {
            YGNodeStyleGetMaxHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetMaxHeight(yogaNode, Float.nan)
            case .point: YGNodeStyleSetMaxHeight(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetMaxHeightPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    /**
     * Convenient alias to `width` and `height` in pixels.
     * Defaults to NAN in case of non-pixel dimension.
     */
    @available(*, deprecated, message: "直接使用 width 和 height，否则 auto 值被忽略")
    private var size: CGSize {
        get {
            let width = YGNodeStyleGetWidth(yogaNode)
            let height = YGNodeStyleGetHeight(yogaNode)

            return CGSize(width: width.unit == .point ? CGFloat(width.value) : CGFloat.nan, height: height.unit == .point ? CGFloat(width.value) : CGFloat.nan)
        }
        set {
            YGNodeStyleSetWidth(yogaNode, Float(newValue.width))
            YGNodeStyleSetHeight(yogaNode, Float(newValue.height))
        }
    }

    /**
     * Border. Defaults to { 0, 0, 0, 0 }.
     */
    private var borderWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .all)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .all, newValue)
        }
    }
    private var borderTopWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .top)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .top, newValue)
        }
    }
    private var borderLeftWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .left)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .left, newValue)
        }
    }
    private var borderBottomWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .bottom)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .bottom, newValue)
        }
    }
    private var borderRightWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .right)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .right, newValue)
        }
    }
    private var borderStartWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .start)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .start, newValue)
        }
    }
    private var borderEndWidth: Float {
        get {
            YGNodeStyleGetBorder(yogaNode, .end)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, .end, newValue)
        }
    }

    /**
     * Margin. Defaults to { 0, 0, 0, 0 }.
     */
    private var margin: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .all)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .all)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .all, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .all, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .all, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginVertical: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .vertical)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .vertical)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .vertical, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .vertical, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .vertical, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginHorizontal: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .horizontal)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .horizontal)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .horizontal, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .horizontal, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .horizontal, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginTop: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .top)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .top)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .top, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .top, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .top, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginLeft: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .left)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .left)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .left, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .left, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .left, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginBottom: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .bottom)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .bottom)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .bottom, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .bottom, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .bottom, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginRight: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .right)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .right)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .right, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .right, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .right, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginStart: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .start)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .start)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .start, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .start, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .start, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var marginEnd: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, .end)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetMarginAuto(yogaNode, .end)
            case .undefined: YGNodeStyleSetMargin(yogaNode, .end, Float.nan)
            case .point: YGNodeStyleSetMargin(yogaNode, .end, newValue.value)
            case .percent: YGNodeStyleSetMarginPercent(yogaNode, .end, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    /**
     * Padding. Defaults to { 0, 0, 0, 0 }.
     */
    private var padding: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .all)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .end, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .end, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .end, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingVertical: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .vertical)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .vertical, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .vertical, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .vertical, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingHorizontal: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .horizontal)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .horizontal, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .horizontal, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .horizontal, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingTop: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .top)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .top, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .top, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .top, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingLeft: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .left)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .left, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .left, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .left, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingBottom: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .bottom)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .bottom, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .bottom, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .bottom, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingRight: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .right)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .right, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .right, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .right, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingStart: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .start)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .start, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .start, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .start, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }
    private var paddingEnd: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, .end)
        }
        set {
            switch newValue.unit {
            case .auto: fallthrough
            case .undefined: YGNodeStyleSetPadding(yogaNode, .end, Float.nan)
            case .point: YGNodeStyleSetPadding(yogaNode, .end, newValue.value)
            case .percent: YGNodeStyleSetPaddingPercent(yogaNode, .end, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    /**
     * Flexbox properties. All zero/disabled by default
     */
    private var flexDirection: YGFlexDirection {
        get {
            YGNodeStyleGetFlexDirection(yogaNode)
        }
        set {
            YGNodeStyleSetFlexDirection(yogaNode, newValue)
        }
    }
    private var justifyContent: YGJustify {
        get {
            YGNodeStyleGetJustifyContent(yogaNode)
        }
        set {
            YGNodeStyleSetJustifyContent(yogaNode, newValue)
        }
    }
    private var alignSelf: YGAlign {
        get {
            YGNodeStyleGetAlignSelf(yogaNode)
        }
        set {
            YGNodeStyleSetAlignSelf(yogaNode, newValue)
        }
    }
    private var alignItems: YGAlign {
        get {
            YGNodeStyleGetAlignItems(yogaNode)
        }
        set {
            YGNodeStyleSetAlignItems(yogaNode, newValue)
        }
    }
    private var alignContent: YGAlign {
        get {
            YGNodeStyleGetAlignContent(yogaNode)
        }
        set {
            YGNodeStyleSetAlignContent(yogaNode, newValue)
        }
    }
    private var position: YGPositionType {
        get {
            YGNodeStyleGetPositionType(yogaNode)
        }
        set {
            YGNodeStyleSetPositionType(yogaNode, newValue)
        }
    }
    private var flexWrap: YGWrap {
        get {
            YGNodeStyleGetFlexWrap(yogaNode)
        }
        set {
            YGNodeStyleSetFlexWrap(yogaNode, newValue)
        }
    }
    private var display: YGDisplay {
        get {
            YGNodeStyleGetDisplay(yogaNode)
        }
        set {
            YGNodeStyleSetDisplay(yogaNode, newValue)
        }
    }

    private var flex: Float {
        get {
            YGNodeStyleGetFlex(yogaNode)
        }
        set {
            YGNodeStyleSetFlex(yogaNode, newValue)
        }
    }
    private var flexGrow: Float {
        get {
            YGNodeStyleGetFlexGrow(yogaNode)
        }
        set {
            YGNodeStyleSetFlexGrow(yogaNode, newValue)
        }
    }
    private var flexShrink: Float {
        get {
            YGNodeStyleGetFlexShrink(yogaNode)
        }
        set {
            YGNodeStyleSetFlexShrink(yogaNode, newValue)
        }
    }
    private var flexBasis: YGValue {
        get {
            YGNodeStyleGetFlexBasis(yogaNode)
        }
        set {
            switch newValue.unit {
            case .auto: YGNodeStyleSetFlexBasisAuto(yogaNode)
            case .undefined: YGNodeStyleSetFlexBasis(yogaNode, Float.nan)
            case .point: YGNodeStyleSetFlexBasis(yogaNode, newValue.value)
            case .percent: YGNodeStyleSetFlexBasisPercent(yogaNode, newValue.value)
            @unknown default:
                fatalError()
            }
        }
    }

    private var aspectRatio: Float {
        get {
            YGNodeStyleGetAspectRatio(yogaNode)
        }
        set {
            YGNodeStyleSetAspectRatio(yogaNode, newValue)
        }
    }

    /**
     * Interface direction (LTR or RTL)
     */
    private var direction: YGDirection {
        get {
            YGNodeStyleGetDirection(yogaNode)
        }
        set {
            YGNodeStyleSetDirection(yogaNode, newValue)
        }
    }

    /**
     * Clipping properties
     */
    private var overflow: YGOverflow {
        get {
            YGNodeStyleGetOverflow(yogaNode)
        }
        set {
            YGNodeStyleSetOverflow(yogaNode, newValue)
        }
    }

    private var intrinsicContentSizeStore: CGSize

    /**
     * Represents the natural size of the view, which is used when explicit size is not set or is ambiguous.
     * Defaults to `{UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric}`.
     */
    fileprivate var intrinsicContentSize: CGSize {
        get {
            intrinsicContentSizeStore
        }
        set {
            if intrinsicContentSizeStore == newValue {
                return
            }
            intrinsicContentSizeStore = newValue
            if intrinsicContentSizeStore == CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) {
                YGNodeSetMeasureFunc(yogaNode, nil)
            } else {
                YGNodeSetMeasureFunc(yogaNode, ShadowViewMeasure)
            }

            YGNodeMarkDirty(yogaNode)
        }
    }

    private var subviews: [ShadowView]? {
        get {
            var subviewArray: [ShadowView]? = nil;
            let count = YGNodeGetChildCount(yogaNode);
            for i in 0..<count {
                let childNodRef = YGNodeGetChild(yogaNode, i)
                guard (childNodRef != nil) else {
                    continue
                }
                guard let shadowViewPointer = YGNodeGetContext(yogaNode) else {
                    continue
                }
                if subviewArray == nil {
                    subviewArray = []
                }
                let shadowView = Unmanaged<ShadowView>.fromOpaque(shadowViewPointer).takeUnretainedValue()
                subviewArray?.append(shadowView)
            }

            return subviewArray
        }
    }

    private var superview: ShadowView? {
        get {
            let ownerNodeRef = YGNodeGetOwner(yogaNode)
            guard ownerNodeRef != nil else {
                return nil;
            }
            guard let shadowViewPointer = YGNodeGetContext(ownerNodeRef) else {
                return nil;
            }

            return Unmanaged<ShadowView>.fromOpaque(shadowViewPointer).takeUnretainedValue()
        }
    }

    init() {
        intrinsicContentSizeStore = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        yogaNode = YGNodeNewWithConfig(type(of: self).yogaConfig())
        YGNodeSetContext(yogaNode, Unmanaged.passUnretained(self).toOpaque())
        // print
    }

    /// Yoga Config which will be used to create `yogaNode` property.
    /// Override in subclass to enable special Yoga features.
    /// Defaults to suitable to current device configuration.
    ///
    /// - Returns: YGConfigRef?
    private class func yogaConfig() -> YGConfigRef? {
        globalYogaConfig
    }

    private func insertSubview(_ view: ShadowView, at index: Int) {
        assert(canHaveSubviews(), "Attempt to insert subview inside leaf view.")
        if !isYogaLeafNode() {
            YGNodeInsertChild(yogaNode, view.yogaNode, UInt32(index))
        }
    }

    private func removeSubview(_ subview: ShadowView) {
        if !isYogaLeafNode() {
            YGNodeRemoveChild(yogaNode, subview.yogaNode)
        }
    }

    // MARK: - Layout

    /// Initiates layout starts from the view.
    ///
    /// - Parameters:
    ///   - minimumSize: CGSize 最小大小，会修改 yogaNode minWidth/Height
    ///   - maximumSize: CGSize
    ///   - layoutDirection: 布局方向
    ///   - layoutContext: 布局上下文
    private func layout(minimumSize: CGSize, maximumSize: CGSize, layoutDirection: UIUserInterfaceLayoutDirection, layoutContext: inout LayoutContext) {
        let oldMinimumSize = CGSize(width: CoreGraphicsFloatFromYogaValue(YGNodeStyleGetMinWidth(yogaNode), 0.0), height: CoreGraphicsFloatFromYogaValue(YGNodeStyleGetMinHeight(yogaNode), 0.0))
        if oldMinimumSize != minimumSize {
            YGNodeStyleSetMinWidth(yogaNode, YogaFloatFromCoreGraphicsFloat(minimumSize.width))
            YGNodeStyleSetMinHeight(yogaNode, YogaFloatFromCoreGraphicsFloat(minimumSize.height))
        }

        YGNodeCalculateLayout(yogaNode, YogaFloatFromCoreGraphicsFloat(maximumSize.width), YogaFloatFromCoreGraphicsFloat(maximumSize.height), YogaLayoutDirectionFromUIKitLayoutDirection(layoutDirection))

        assert(!YGNodeIsDirty(yogaNode), "Attempt to get layout metrics from dirtied Yoga node.")

        if !YGNodeGetHasNewLayout(yogaNode) {
            return;
        }

        YGNodeSetHasNewLayout(yogaNode, false)

        let layoutMetrics = LayoutMetricsFromYogaNode(yogaNode)

        layoutContext.absolutePosition.x += layoutMetrics.frame.origin.x;
        layoutContext.absolutePosition.y += layoutMetrics.frame.origin.y;

        layout(metrics: layoutMetrics, layoutContext: layoutContext)

        layoutSubviews(context: &layoutContext)
    }

    /**
     * Applies computed layout metrics to the view.
     */
    private func layout(metrics: LayoutMetrics, layoutContext: LayoutContext) {
        if layoutMetrics != metrics {
            layoutMetrics = metrics
            layoutContext.affectedShadowViews.add(self)
        }
    }

    /**
     * Calculates (if needed) and applies layout to subviews.
     */
    private func layoutSubviews(context: inout LayoutContext) {
        if let layoutMetricsNotNil = layoutMetrics, layoutMetricsNotNil.displayType == .none {
            return;
        }

        let count = YGNodeGetChildCount(yogaNode);
        for i in 0..<count {
            let childYogaNode = YGNodeGetChild(yogaNode, i)

            assert(!YGNodeIsDirty(childYogaNode), "Attempt to get layout metrics from dirtied Yoga node.")

            if !YGNodeGetHasNewLayout(childYogaNode) {
                continue
            }

            guard let childShadowViewPointer = YGNodeGetContext(childYogaNode) else {
                continue
            }

            YGNodeSetHasNewLayout(childYogaNode, false)

            let childLayoutMetrics = LayoutMetricsFromYogaNode(childYogaNode)

            context.absolutePosition.x += childLayoutMetrics.frame.origin.x;
            context.absolutePosition.y += childLayoutMetrics.frame.origin.y;

            let childShadowView = Unmanaged<ShadowView>.fromOpaque(childShadowViewPointer).takeUnretainedValue()

            childShadowView.layout(metrics: childLayoutMetrics, layoutContext: context)

            // Recursive call.
            childShadowView.layoutSubviews(context: &context)
        }
    }

    /**
     * Measures shadow view without side-effects.
     * Default implementation uses Yoga for measuring.
     */
    private func sizeThatFitsMinimumSize(_ minimumSize: CGSize, maximumSize: CGSize) -> CGSize {
        let clonedYogaNode = YGNodeClone(yogaNode)
        let constraintYogaNodeOrNil = YGNodeNewWithConfig(type(of: self).yogaConfig())
        
        guard let constraintYogaNode = constraintYogaNodeOrNil else {
            return .zero
        }

        YGNodeInsertChild(constraintYogaNode, clonedYogaNode, 0)

        YGNodeStyleSetMinWidth(constraintYogaNode, YogaFloatFromCoreGraphicsFloat(minimumSize.width))
        YGNodeStyleSetMinHeight(constraintYogaNode, YogaFloatFromCoreGraphicsFloat(minimumSize.height))
        YGNodeStyleSetMaxWidth(constraintYogaNode, YogaFloatFromCoreGraphicsFloat(maximumSize.width))
        YGNodeStyleSetMaxHeight(constraintYogaNode, YogaFloatFromCoreGraphicsFloat(maximumSize.height))

        YGNodeCalculateLayout(constraintYogaNode, Float.nan, Float.nan, YogaLayoutDirectionFromUIKitLayoutDirection(layoutMetrics?.layoutDirection ?? .leftToRight))

        let measuredSize = CGSize(width: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetWidth(constraintYogaNode)), height: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetHeight(constraintYogaNode)))

        YGNodeFreeRecursiveNew(root: constraintYogaNode)

        return measuredSize
    }

    /**
     * Returns whether or not this view can have any subviews.
     * Adding/inserting a child view to leaf view (`canHaveSubviews` equals `NO`)
     * will throw an error.
     * Return `NO` for components which must not have any descendants
     * (like <Image>, for example.)
     * Defaults to `YES`. Can be overridden in subclasses.
     * Don't confuse this with `isYogaLeafNode`.
     */
    private func canHaveSubviews() -> Bool {
        true;
    }

    /**
     * Returns whether or not this node acts as a leaf node in the eyes of Yoga.
     * For example `TextShadowView` has children which it does not want Yoga
     * to lay out so in the eyes of Yoga it is a leaf node.
     * Defaults to `NO`. Can be overridden in subclasses.
     * Don't confuse this with `canHaveSubviews`.
     */
    private func isYogaLeafNode() -> Bool {
        false;
    }

    /**
     * Computes the recursive offset, meaning the sum of all descendant offsets -
     * this is the sum of all positions inset from parents. This is not merely the
     * sum of `top`/`left`s, as this function uses the *actual* positions of
     * children, not the style specified positions - it computes this based on the
     * resulting layout. It does not yet compensate for native scroll view insets or
     * transforms or anchor points.
     */
    private func measureLayoutRelativeToAncestor(_ ancestor: ShadowView) -> CGRect {
        var offset = CGPoint.zero
        var shadowView: ShadowView? = self
        while shadowView != nil && shadowView !== ancestor {
            offset.x += shadowView?.layoutMetrics?.frame.origin.x ?? 0;
            offset.y += shadowView?.layoutMetrics?.frame.origin.y ?? 0;
            shadowView = shadowView?.superview;
        }
        if ancestor !== shadowView {
            return .null
        }

        return CGRect(origin: offset, size: layoutMetrics?.frame.size ?? .zero)
    }

    private func viewIsDescendantOf(_ ancestor: ShadowView) -> Bool {
        var shadowView: ShadowView? = self
        while shadowView != nil && shadowView !== ancestor {
            shadowView = shadowView?.superview;
        }

        return ancestor === shadowView
    }
}
