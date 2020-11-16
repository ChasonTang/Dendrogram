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

fileprivate enum DMDisplayType {
    private case none
    private case flex
    // 未实现 inline
    private case inline
}

fileprivate struct DMLayoutMetrics {
    private let frame: CGRect

    private let contentFrame: CGRect

    private let borderWidth: UIEdgeInsets

    private let layoutDirection: UIUserInterfaceLayoutDirection
}

fileprivate struct DMLayoutContext {
    private let absolutePosition: CGPoint
    private let affectedShadowViews: NSHashTable<ShadowView>
    private let other: NSHashTable<String>
}

fileprivate class ShadowView {

    private let yogaNode: YGNodeRef

    private var layoutMetrics: DMLayoutMetrics;

    /**
     * Position and dimensions.
     * Defaults to { 0, 0, NAN, NAN }.
     */
    private var top: YGValue
    private var left: YGValue
    private var bottom: YGValue
    private var right: YGValue
    private var start: YGValue
    private var end: YGValue

    private var width: YGValue
    private var height: YGValue

    private var minWidth: YGValue
    private var maxWidth: YGValue
    private var minHeight: YGValue
    private var maxHeight: YGValue

    /**
     * Convenient alias to `width` and `height` in pixels.
     * Defaults to NAN in case of non-pixel dimension.
     */
    private var size: CGSize

    /**
     * Border. Defaults to { 0, 0, 0, 0 }.
     */
    private var borderWidth: Float32
    private var borderTopWidth: Float32
    private var borderLeftWidth: Float32
    private var borderBottomWidth: Float32
    private var borderRightWidth: Float32
    private var borderStartWidth: Float32
    private var borderEndWidth: Float32

    /**
     * Margin. Defaults to { 0, 0, 0, 0 }.
     */
    private var margin: YGValue
    private var marginVertical: YGValue
    private var marginVertical: YGValue
    private var marginTop: YGValue
    private var marginLeft: YGValue
    private var marginBottom: YGValue
    private var marginRight: YGValue
    private var marginStart: YGValue
    private var marginEnd: YGValue

    /**
     * Padding. Defaults to { 0, 0, 0, 0 }.
     */
    private var padding: YGValue
    private var paddingVertical: YGValue
    private var paddingHorizontal: YGValue
    private var paddingTop: YGValue
    private var paddingLeft: YGValue
    private var paddingBottom: YGValue
    private var paddingRight: YGValue
    private var paddingStart: YGValue
    private var paddingEnd: YGValue

    /**
     * Flexbox properties. All zero/disabled by default
     */
    private var flexDirection: YGFlexDirection
    private var justifyContent: YGJustify
    private var justifyContent: YGAlign
    private var justifyContent: YGAlign
    private var alignContent: YGAlign
    private var position: YGPositionType
    private var flexWrap: YGWrap
    private var display: YGDisplay

    private var flex: Float32
    private var flexGrow: Float32
    private var flexShrink: Float32
    private var flexBasis: YGValue

    private var aspectRatio: Float32

    /**
     * Interface direction (LTR or RTL)
     */
    private var direction: YGDirection

    /**
     * Clipping properties
     */
    private var overflow: YGOverflow

    /**
     * Represents the natural size of the view, which is used when explicit size is not set or is ambiguous.
     * Defaults to `{UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric}`.
     */
    private var intrinsicContentSize: CGSize

    // TODO(唐佳诚): 修改类型为 [ShadowView]
    private final var subviews: [ShadowView]? {
        get {
            nil;
        }
    }

    // TODO(唐佳诚)：修改类型为 ShadowView
    private final var superview: ShadowView? {
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

    private final func insertSubview(_ view: ShadowView, at index: Int) {
        // TODO(唐佳诚): 插入 yogaNode
    }

    private final func removeSubview(_ subview: ShadowView) {
        // TODO(唐佳诚)：判断 isYogaLeafNode 如果不是叶节点直接 YGNodeRemoveChild
    }

    // MARK: - Layout

    /**
     * Initiates layout starts from the view.
     */
    private final func layout(minimumSize: CGSize, maximumSize: CGSize, layoutDirection: UIUserInterfaceLayoutDirection, layoutContext:)
}
