//
//  ShadowViewTests.swift
//  ExampleTests
//
//  Created by 唐佳诚 on 2020/11/23.
//

import UIKit
import yoga
@testable import Dendrogram
import XCTest

private final class ShadowViewTests: XCTestCase {

    private var parentView: RootShadowView?

    fileprivate override func setUp() {
        super.setUp()

        parentView = RootShadowView(shadowView: ShadowView())
        YGNodeStyleSetFlexDirection(parentView?.shadowView.yogaNode, .column)
        YGNodeStyleSetWidth(parentView?.shadowView.yogaNode, 440)
        YGNodeStyleSetHeight(parentView?.shadowView.yogaNode, 440)
    }

    private func shadowView(config configBlock: (YGNodeRef?) -> ()) -> ShadowView {
        let shadowView = ShadowView()
        configBlock(shadowView.yogaNode)

        return shadowView
    }

    // Just a basic sanity test to ensure css-layout is applied correctly in the context of our shadow view hierarchy.
    //
    // ====================================
    // ||             header             ||
    // ====================================
    // ||       ||              ||       ||
    // || left  ||    center    || right ||
    // ||       ||              ||       ||
    // ====================================
    // ||             footer             ||
    // ====================================
    //

    func testApplyingLayoutRecursivelyToShadowView() {
        let leftView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        let centerView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 2)
            YGNodeStyleSetMargin(node, .left, 10)
            YGNodeStyleSetMargin(node, .right, 10)
        }

        let rightView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        let mainView = shadowView { (node) in
            YGNodeStyleSetFlexDirection(node, .row)
            YGNodeStyleSetFlex(node, 2)
            YGNodeStyleSetMargin(node, .top, 10)
            YGNodeStyleSetMargin(node, .bottom, 10)
        }

        mainView.insertSubview(leftView, at: 0)
        mainView.insertSubview(centerView, at: 1)
        mainView.insertSubview(rightView, at: 2)

        let headerView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        let footerView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        YGNodeStyleSetPadding(parentView?.shadowView.yogaNode, .left, 10)
        YGNodeStyleSetPadding(parentView?.shadowView.yogaNode, .top, 10)
        YGNodeStyleSetPadding(parentView?.shadowView.yogaNode, .right, 10)
        YGNodeStyleSetPadding(parentView?.shadowView.yogaNode, .bottom, 10)

        parentView?.shadowView.insertSubview(headerView, at: 0)
        parentView?.shadowView.insertSubview(mainView, at: 1)
        parentView?.shadowView.insertSubview(footerView, at: 2)

        parentView?.layout(affectedShadowViews: NSHashTable.weakObjects())

        XCTAssertTrue(parentView?.shadowView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 0, y: 0, width: 440, height: 440))
        XCTAssertTrue(parentView?.shadowView.paddingAsInsets == UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        XCTAssertTrue(headerView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 10, y: 10, width: 420, height: 100))
        XCTAssertTrue(mainView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 10, y: 120, width: 420, height: 200))
        XCTAssertTrue(footerView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 10, y: 330, width: 420, height: 100))

        XCTAssertTrue(leftView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 10, y: 120, width: 100, height: 200))
        XCTAssertTrue(centerView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 120, y: 120, width: 200, height: 200))
        XCTAssertTrue(rightView.measureLayoutRelativeToAncestor(parentView?.shadowView) == CGRect(x: 330, y: 120, width: 100, height: 200))
    }

    func testAncestorCheck() {
        let centerView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        let mainView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        mainView.insertSubview(centerView, at: 0)

        let footerView = shadowView { (node) in
            YGNodeStyleSetFlex(node, 1)
        }

        parentView?.shadowView.insertSubview(mainView, at: 0)
        parentView?.shadowView.insertSubview(footerView, at: 1)

        XCTAssertTrue(centerView.viewIsDescendantOf(mainView))
        XCTAssertFalse(footerView.viewIsDescendantOf(mainView))
    }

    private func withShadowView(style configBlock: (_ node: YGNodeRef?) -> Void, assertRelativeLayout expectedRect: CGRect, withIntrinsicContentSize contentSize: CGSize) {
        let view = shadowView(config: configBlock)
        parentView?.shadowView.insertSubview(view, at: 0)
        view.intrinsicContentSize = contentSize
        parentView?.layout(affectedShadowViews: NSHashTable.weakObjects())
        let actualRect = view.measureLayoutRelativeToAncestor(parentView?.shadowView)
        XCTAssertTrue(expectedRect == actualRect, "Expected layout to be \(expectedRect), got \(actualRect)")
    }

    func testAssignsSuggestedWidthDimension() {
        withShadowView(style: { (node) in
            YGNodeStyleSetPositionType(node, .absolute)
            YGNodeStyleSetPosition(node, .left, 0)
            YGNodeStyleSetPosition(node, .top, 0)
            YGNodeStyleSetHeight(node, 10)
        }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 3, height: 10), withIntrinsicContentSize: CGSize(width: 3, height: UIView.noIntrinsicMetric))
    }

    func testAssignsSuggestedHeightDimension() {
        withShadowView(style: { (node) in
            YGNodeStyleSetPositionType(node, .absolute)
            YGNodeStyleSetPosition(node, .left, 0)
            YGNodeStyleSetPosition(node, .top, 0)
            YGNodeStyleSetWidth(node, 10)
        }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 10, height: 4), withIntrinsicContentSize: CGSize(width: UIView.noIntrinsicMetric, height: 4))
    }

    func testDoesNotOverrideDimensionStyleWithSuggestedDimensions() {
        withShadowView(style: { (node) in
            YGNodeStyleSetPositionType(node, .absolute);
            YGNodeStyleSetPosition(node, .left, 0);
            YGNodeStyleSetPosition(node, .top, 0);
            YGNodeStyleSetWidth(node, 10);
            YGNodeStyleSetHeight(node, 10);
        }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 10, height: 10), withIntrinsicContentSize: CGSize(width: 3, height: 4))
    }

    func testDoesNotAssignSuggestedDimensionsWhenStyledWithFlexAttribute() {
        let parentWidth = YGNodeStyleGetWidth(parentView?.shadowView.yogaNode).value
        let parentHeight = YGNodeStyleGetHeight(parentView?.shadowView.yogaNode).value
        withShadowView(style: { (node) in
            YGNodeStyleSetFlex(node, 1)
        }, assertRelativeLayout: CGRect(x: 0, y: 0, width: CGFloat(parentWidth), height: CGFloat(parentHeight)), withIntrinsicContentSize: CGSize(width: 3, height: 4))
    }
}
