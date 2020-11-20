//
//  Layout.swift
//  Dendrogram
//
//  Created by 唐佳诚 on 2020/11/19.
//

import Foundation
import yoga

enum DisplayType {
    case none
    case flex
    // 未实现 inline
    case inline
}

struct LayoutMetrics {

    let frame: CGRect

    let contentFrame: CGRect

    let borderWidth: UIEdgeInsets

    let displayType: DisplayType

    let layoutDirection: UIUserInterfaceLayoutDirection
}

struct LayoutContext {

    var absolutePosition: CGPoint

    let affectedShadowViews: NSHashTable<ShadowView>

    /// 实际上没有使用
    let other: NSHashTable<NSString>
}

@available(*, deprecated, message: "实现了 Equatable 协议，直接使用 == 比较")
fileprivate func LayoutMetricsEqualToLayoutMetrics(_ a: LayoutMetrics, _ b: LayoutMetrics) -> Bool {
    a.frame == b.frame && a.contentFrame == b.contentFrame && a.borderWidth == b.borderWidth && a.layoutDirection == b.layoutDirection
}

func LayoutMetricsFromYogaNode(_ yogaNode: YGNodeRef) -> LayoutMetrics {
    let frame = CGRect(x: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetLeft(yogaNode)), y: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetTop(yogaNode)), width: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetWidth(yogaNode)), height: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetHeight(yogaNode)))

    let padding = UIEdgeInsets(top: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetPadding(yogaNode, .top)), left: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetPadding(yogaNode, .left)), bottom: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetPadding(yogaNode, .bottom)), right: CoreGraphicsFloatFromYogaFloat(YGNodeLayoutGetPadding(yogaNode, .right)))

    let borderWidth = UIEdgeInsets(top: CoreGraphicsFloatFromYogaFloat(YGNodeStyleGetBorder(yogaNode, .top)), left: CoreGraphicsFloatFromYogaFloat(YGNodeStyleGetBorder(yogaNode, .left)), bottom: CoreGraphicsFloatFromYogaFloat(YGNodeStyleGetBorder(yogaNode, .bottom)), right: CoreGraphicsFloatFromYogaFloat(YGNodeStyleGetBorder(yogaNode, .right)))

    let compoundInsets = UIEdgeInsets(top: borderWidth.top + padding.top, left: borderWidth.left + padding.left, bottom: borderWidth.bottom + padding.bottom, right: borderWidth.right + padding.right)

    let bounds = CGRect(origin: .zero, size: frame.size)
    let contentFrame = bounds.inset(by: compoundInsets)

    return LayoutMetrics(frame: frame, contentFrame: contentFrame, borderWidth: borderWidth, displayType: DisplayTypeFromYogaDisplayType(YGNodeStyleGetDisplay(yogaNode)), layoutDirection: UIKitLayoutDirectionFromYogaLayoutDirection(YGNodeLayoutGetDirection(yogaNode)))
}

/**
 * Converts float values between Yoga and CoreGraphics representations,
 * especially in terms of edge cases.
 */
func YogaFloatFromCoreGraphicsFloat(_ value: CGFloat) -> Float {
    if value == CGFloat.greatestFiniteMagnitude || value.isNaN || value.isInfinite {
        return Float.nan
    }

    return Float(value)
}

func CoreGraphicsFloatFromYogaFloat(_ value: Float) -> CGFloat {
    if value == Float.nan || value.isNaN || value.isInfinite {
        return CGFloat.greatestFiniteMagnitude
    }

    return CGFloat(value)
}

/**
 * Converts compound `YGValue` to simple `CGFloat` value.
 */
func CoreGraphicsFloatFromYogaValue(_ value: YGValue, _ baseFloatValue: CGFloat) -> CGFloat {
    switch value.unit {
    case .point:
        return CoreGraphicsFloatFromYogaFloat(value.value)
    case .percent:
        return CoreGraphicsFloatFromYogaFloat(value.value) * baseFloatValue
    case .auto: fallthrough
    case .undefined:
        return baseFloatValue
    @unknown default:
        return baseFloatValue
    }
}

/**
 * Converts `YGDirection` to `UIUserInterfaceLayoutDirection` and vise versa.
 */
func YogaLayoutDirectionFromUIKitLayoutDirection(_ direction: UIUserInterfaceLayoutDirection) -> YGDirection {
    switch direction {
    case .rightToLeft:
        return .RTL
    case .leftToRight:
        return .LTR
    @unknown default:
        return .LTR
    }
}

func UIKitLayoutDirectionFromYogaLayoutDirection(_ direction: YGDirection) -> UIUserInterfaceLayoutDirection {
    switch direction {
    case .inherit: fallthrough
    case .LTR:
        return .leftToRight
    case .RTL:
        return .rightToLeft
    @unknown default:
        return .leftToRight
    }
}

/**
 * Converts `YGDisplay` to `DisplayType` and vise versa.
 */
fileprivate func YogaDisplayTypeFromDisplayType(_ displayType: DisplayType) -> YGDisplay {
    switch displayType {
    case .none:
        return .none
    case .flex:
        return .flex
    case .inline:
        assert(false, "DisplayTypeInline cannot be converted to YGDisplay value.")

        return .none
    }
}

fileprivate func DisplayTypeFromYogaDisplayType(_ displayType: YGDisplay) -> DisplayType {
    switch displayType {
    case .flex:
        return .flex
    case .none:
        return .none
    @unknown default:
        return .none
    }
}

extension LayoutMetrics: Equatable {

    public static func ==(a: LayoutMetrics, b: LayoutMetrics) -> Bool {
        a.frame == b.frame && a.contentFrame == b.contentFrame && a.borderWidth == b.borderWidth && a.layoutDirection == b.layoutDirection
    }
}
