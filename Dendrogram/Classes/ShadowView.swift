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

fileprivate let globalYogaConfig = YogaConfig();

fileprivate struct YogaConfig {

    let yogaConfig = DMYGConfigNew();

    init() {
        YGConfigSetPointScaleFactor(yogaConfig, Float(screenScale))
        YGConfigSetUseLegacyStretchBehaviour(yogaConfig, true)
    }
}

fileprivate enum DisplayType {
    case none
    case flex
    // 未实现 inline
    case inline
}

fileprivate struct LayoutMetrics {

    private let frame: CGRect

    private let contentFrame: CGRect

    private let borderWidth: UIEdgeInsets

    private let layoutDirection: UIUserInterfaceLayoutDirection
}

fileprivate struct LayoutContext {

    private let absolutePosition: CGPoint

    private let affectedShadowViews: NSHashTable<ShadowView>

    /// 实际上没有使用
    private let other: NSHashTable<NSString>
}

fileprivate final class ShadowView {

    private let yogaNode: YGNodeRef

    private var layoutMetrics: LayoutMetrics;

    /**
     * Position and dimensions.
     * Defaults to { 0, 0, NAN, NAN }.
     */
    private var top: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeTop)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeTop, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeTop, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeTop, newValue.value)
            }
        }
    }
    private var left: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeLeft)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeLeft, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeLeft, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeLeft, newValue.value)
            }
        }
    }
    private var bottom: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeBottom)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeBottom, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeBottom, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeBottom, newValue.value)
            }
        }
    }
    private var right: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeRight)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeRight, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeRight, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeRight, newValue.value)
            }
        }
    }
    private var start: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeStart)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeStart, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeStart, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeStart, newValue.value)
            }
        }
    }
    private var end: YGValue {
        get {
            YGNodeStyleGetPosition(yogaNode, YGEdgeEnd)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetPosition(yogaNode, YGEdgeEnd, Float.nan)
            case YGUnitPoint: YGNodeStyleSetPosition(yogaNode, YGEdgeEnd, newValue.value)
            case YGUnitPercent: YGNodeStyleSetPositionPercent(yogaNode, YGEdgeEnd, newValue.value)
            }
        }
    }

    private var width: YGValue {
        get {
            YGNodeStyleGetWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetWidthAuto(yogaNode)
            case YGUnitUndefined: YGNodeStyleSetWidth(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetWidth(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetWidthPercent(yogaNode, newValue.value)
            }
        }
    }
    private var height: YGValue {
        get {
            YGNodeStyleGetHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetHeightAuto(yogaNode)
            case YGUnitUndefined: YGNodeStyleSetHeight(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetHeight(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetHeightPercent(yogaNode, newValue.value)
            }
        }
    }

    private var minWidth: YGValue {
        get {
            YGNodeStyleGetMinWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMinWidth(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMinWidth(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMinWidthPercent(yogaNode, newValue.value)
            }
        }
    }
    private var maxWidth: YGValue {
        get {
            YGNodeStyleGetMaxWidth(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMaxWidth(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMaxWidth(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMaxWidthPercent(yogaNode, newValue.value)
            }
        }
    }
    private var minHeight: YGValue {
        get {
            YGNodeStyleGetMinHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMinHeight(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMinHeight(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMinHeightPercent(yogaNode, newValue.value)
            }
        }
    }
    private var maxHeight: YGValue {
        get {
            YGNodeStyleGetMaxHeight(yogaNode)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMaxHeight(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMaxHeight(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMaxHeightPercent(yogaNode, newValue.value)
            }
        }
    }

    /**
     * Convenient alias to `width` and `height` in pixels.
     * Defaults to NAN in case of non-pixel dimension.
     */
    private var size: CGSize {
        get {
            let width = YGNodeStyleGetWidth(yogaNode)
            let height = YGNodeStyleGetHeight(yogaNode)

            CGSize(width: width.unit == YGUnitPoint ? width.value : CGFloat.nan, height: CGFloat.nan)
        }
        set {
            YGNodeStyleSetWidth(yogaNode, newValue.width)
            YGNodeStyleSetHeight(yogaNode, newValue.height)
        }
    }

    /**
     * Border. Defaults to { 0, 0, 0, 0 }.
     */
    private var borderWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeAll)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeAll, newValue)
        }
    }
    private var borderTopWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeTop)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeTop, newValue)
        }
    }
    private var borderLeftWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeLeft)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeLeft, newValue)
        }
    }
    private var borderBottomWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeBottom)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeBottom, newValue)
        }
    }
    private var borderRightWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeRight)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeRight, newValue)
        }
    }
    private var borderStartWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeStart)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeStart, newValue)
        }
    }
    private var borderEndWidth: Float32 {
        get {
            YGNodeStyleGetBorder(yogaNode, YGEdgeEnd)
        }
        set {
            YGNodeStyleSetBorder(yogaNode, YGEdgeEnd, newValue)
        }
    }

    /**
     * Margin. Defaults to { 0, 0, 0, 0 }.
     */
    private var margin: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeAll)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeAll)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeAll, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeAll, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeAll, newValue.value)
            }
        }
    }
    private var marginVertical: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeVertical)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeVertical)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeVertical, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeVertical, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeVertical, newValue.value)
            }
        }
    }
    private var marginHorizontal: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeHorizontal)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeHorizontal)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeHorizontal, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeHorizontal, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeHorizontal, newValue.value)
            }
        }
    }
    private var marginTop: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeTop)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeTop)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeTop, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeTop, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeTop, newValue.value)
            }
        }
    }
    private var marginLeft: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeLeft)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeLeft)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeLeft, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeLeft, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeLeft, newValue.value)
            }
        }
    }
    private var marginBottom: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeBottom)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeBottom)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeBottom, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeBottom, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeBottom, newValue.value)
            }
        }
    }
    private var marginRight: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeRight)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeRight)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeRight, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeRight, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeRight, newValue.value)
            }
        }
    }
    private var marginStart: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeStart)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeStart)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeStart, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeStart, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeStart, newValue.value)
            }
        }
    }
    private var marginEnd: YGValue {
        get {
            YGNodeStyleGetMargin(yogaNode, YGEdgeEnd)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: YGNodeStyleSetMarginAuto(yogaNode, YGEdgeEnd)
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeEnd, newValue.value)
            }
        }
    }

    /**
     * Padding. Defaults to { 0, 0, 0, 0 }.
     */
    private var padding: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeAll)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeEnd, newValue.value)
            }
        }
    }
    private var paddingVertical: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeVertical)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeVertical, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeVertical, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeVertical, newValue.value)
            }
        }
    }
    private var paddingHorizontal: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeHorizontal)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeHorizontal, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeHorizontal, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeHorizontal, newValue.value)
            }
        }
    }
    private var paddingTop: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeTop)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeTop, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeTop, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeTop, newValue.value)
            }
        }
    }
    private var paddingLeft: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeLeft)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeLeft, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeLeft, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeLeft, newValue.value)
            }
        }
    }
    private var paddingBottom: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeBottom)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeBottom, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeBottom, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeBottom, newValue.value)
            }
        }
    }
    private var paddingRight: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeRight)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeRight, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeRight, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeRight, newValue.value)
            }
        }
    }
    private var paddingStart: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeStart)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeStart, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeStart, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeStart, newValue.value)
            }
        }
    }
    private var paddingEnd: YGValue {
        get {
            YGNodeStyleGetPadding(yogaNode, YGEdgeEnd)
        }
        set {
            switch newValue.unit {
            case YGUnitAuto: fallthrough
            case YGUnitUndefined: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, Float.nan)
            case YGUnitPoint: YGNodeStyleSetMargin(yogaNode, YGEdgeEnd, newValue.value)
            case YGUnitPercent: YGNodeStyleSetMarginPercent(yogaNode, YGEdgeEnd, newValue.value)
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

    private var flex: Float32 {
        get {
            YGNodeStyleGetFlex(yogaNode)
        }
        set {
            YGNodeStyleSetFlex(yogaNode, newValue)
        }
    }
    private var flexGrow: Float32 {
        get {
            YGNodeStyleGetFlexGrow(yogaNode)
        }
        set {
            YGNodeStyleSetFlexGrow(yogaNode, newValue)
        }
    }
    private var flexShrink: Float32 {
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
            case YGUnitAuto: YGNodeStyleSetFlexBasisAuto(yogaNode)
            case YGUnitUndefined: YGNodeStyleSetFlexBasis(yogaNode, Float.nan)
            case YGUnitPoint: YGNodeStyleSetFlexBasis(yogaNode, newValue.value)
            case YGUnitPercent: YGNodeStyleSetFlexBasisPercent(yogaNode, newValue.value)
            }
        }
    }

    private var aspectRatio: Float32 {
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
    private var intrinsicContentSize: CGSize {
        get {
            intrinsicContentSizeStore
        }
        set {
            if intrinsicContentSizeStore.equalTo(newValue) {
                return
            }
            intrinsicContentSizeStore = newValue
            if intrinsicContentSizeStore.equalTo(CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)) {
                YGNodeSetMeasureFunc(yogaNode, nil)
            } else {
                // TODO(唐佳诚): 设置
//                YGNodeSetMeasureFunc(yogaNode, YGMeasureFunc(<#T##some: CFunctionPointer<(YGNodeRef?, Float, YGMeasureMode, Float, YGMeasureMode) -> YGSize>##CFunctionPointer<(YGNodeRef?, Swift.Float, YGMeasureMode, Swift.Float, YGMeasureMode) -> YGSize>#>))
            }

            YGNodeMarkDirty(yogaNode)
        }
    }

    // TODO(唐佳诚): 修改类型为 [ShadowView]
    private var subviews: [ShadowView]? {
        get {
            nil;
        }
    }

    // TODO(唐佳诚)：修改类型为 ShadowView
    private var superview: ShadowView? {
        get {
            nil;
        }
    }

    init() {
        // TODO(唐佳诚)：初始化
    }

    /// Yoga Config which will be used to create `yogaNode` property.
    /// Override in subclass to enable special Yoga features.
    /// Defaults to suitable to current device configuration.
    ///
    /// - Returns: YGConfigRef
    private class func yogaConfig() -> YGConfigRef {
        globalYogaConfig.yogaConfig
    }

    private func insertSubview(_ view: ShadowView, at index: Int) {
        // TODO(唐佳诚): 插入 yogaNode
    }

    private func removeSubview(_ subview: ShadowView) {
        // TODO(唐佳诚)：判断 isYogaLeafNode 如果不是叶节点直接 YGNodeRemoveChild
    }

    // MARK: - Layout

    /**
     * Initiates layout starts from the view.
     */
    private func layout(minimumSize: CGSize, maximumSize: CGSize, layoutDirection: UIUserInterfaceLayoutDirection, layoutContext: LayoutContext) {

    }

    /**
     * Applies computed layout metrics to the view.
     */
    private func layout(metrics: LayoutMetrics, layoutContext: LayoutContext) {

    }

    /**
     * Calculates (if needed) and applies layout to subviews.
     */
    private func layoutSubviews(context: LayoutContext) {

    }

    /**
     * Measures shadow view without side-effects.
     * Default implementation uses Yoga for measuring.
     */
    private func sizeThatFitsMinimumSize(_ minimumSize: CGSize, maximumSize: CGSize) -> CGSize {
        // TODO(唐佳诚): 重写
        .zero
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
     * For example `RCTTextShadowView` has children which it does not want Yoga
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
        // TODO(唐佳诚): 重写
        .zero
    }

    private func viewIsDescendantOf(_ ancestor: ShadowView) -> Bool {
        // TODO(唐佳诚): 重写
        false
    }
}
