//
//  ShadowViewTests.swift
//  ExampleTests
//
//  Created by 唐佳诚 on 2020/11/23.
//

import Quick
import Nimble
import yoga
@testable import Dendrogram

private final class ShadowViewTests: QuickSpec {

    override func spec() {
        var parentView: ShadowView?

        func _shadowView(configBlock: (YGNodeRef?) -> Void) -> ShadowView {
            let shadowView = ShadowView()
            configBlock(shadowView.yogaNode)

            return shadowView
        }

        func _withShadowView(configBlock: (YGNodeRef?) -> Void, assertRelativeLayout expectedRect: CGRect, withIntrinsicContentSize contentSize: CGSize) {
            let view = _shadowView(configBlock: configBlock)
            parentView?.insertSubview(view, at: 0)
            view.intrinsicContentSize = contentSize
            expect(parentView).notTo(beNil())
            guard let parentView = parentView else {
                return
            }
            let rootShadowView = RootShadowView(shadowView: parentView)
            rootShadowView.layout(affectedShadowViews: NSHashTable.weakObjects())
            let actualRect = view.measureLayoutRelativeToAncestor(parentView)
            expect(actualRect == expectedRect).to(beTrue(), description: "Expected layout to be \(expectedRect), got \(actualRect)")
        }

        beforeEach {
            parentView = ShadowView()
            YGNodeStyleSetFlexDirection(parentView?.yogaNode, .column)
            YGNodeStyleSetWidth(parentView?.yogaNode, 440)
            YGNodeStyleSetHeight(parentView?.yogaNode, 440)
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
        it("testApplyingLayoutRecursivelyToShadowView") {
            let leftView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            let centerView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 2)
                YGNodeStyleSetMargin(node, .left, 10)
                YGNodeStyleSetMargin(node, .right, 10)
            }
            let rightView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            let mainView = _shadowView { (node) in
                YGNodeStyleSetFlexDirection(node, .row)
                YGNodeStyleSetFlex(node, 2)
                YGNodeStyleSetMargin(node, .top, 10)
                YGNodeStyleSetMargin(node, .bottom, 10)
            }
            mainView.insertSubview(leftView, at: 0)
            mainView.insertSubview(centerView, at: 1)
            mainView.insertSubview(rightView, at: 2)
            let headerView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            let footerView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            YGNodeStyleSetPadding(parentView?.yogaNode, .left, 10)
            YGNodeStyleSetPadding(parentView?.yogaNode, .top, 10)
            YGNodeStyleSetPadding(parentView?.yogaNode, .right, 10)
            YGNodeStyleSetPadding(parentView?.yogaNode, .bottom, 10)
            parentView?.insertSubview(headerView, at: 0)
            parentView?.insertSubview(mainView, at: 1)
            parentView?.insertSubview(footerView, at: 2)
            expect(parentView).notTo(beNil())
            guard let parentView = parentView else {
                return
            }
            let rootShadowView = RootShadowView(shadowView: parentView)
            rootShadowView.layout(affectedShadowViews: NSHashTable.weakObjects())
            expect(parentView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 0, y: 0, width: 440, height: 440)).to(beTrue())
            expect(parentView.paddingAsInsets == UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)).to(beTrue())
            expect(headerView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 10, y: 10, width: 420, height: 100)).to(beTrue())
            expect(mainView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 10, y: 120, width: 420, height: 200)).to(beTrue())
            expect(footerView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 10, y: 330, width: 420, height: 100)).to(beTrue())
            expect(leftView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 10, y: 120, width: 100, height: 200)).to(beTrue())
            expect(centerView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 120, y: 120, width: 200, height: 200)).to(beTrue())
            expect(rightView.measureLayoutRelativeToAncestor(parentView) == CGRect(x: 330, y: 120, width: 100, height: 200)).to(beTrue())
        }

        it("testAncestorCheck") {
            let centerView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            let mainView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            mainView.insertSubview(centerView, at: 0)
            let footerView = _shadowView { (node) in
                YGNodeStyleSetFlex(node, 1)
            }
            parentView?.insertSubview(mainView, at: 0)
            parentView?.insertSubview(footerView, at: 1)
            expect(centerView.viewIsDescendantOf(mainView)).to(beTrue())
            expect(footerView.viewIsDescendantOf(mainView)).to(beFalse())
        }

        it("testAssignsSuggestedWidthDimension") {
            _withShadowView(configBlock: { (node) in
                YGNodeStyleSetPositionType(node, .absolute)
                YGNodeStyleSetPosition(node, .left, 0)
                YGNodeStyleSetPosition(node, .top, 0)
                YGNodeStyleSetHeight(node, 10)
            }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 3, height: 10), withIntrinsicContentSize: CGSize(width: 3, height: UIView.noIntrinsicMetric))
        }

        it("testAssignsSuggestedHeightDimension") {
            _withShadowView(configBlock: { (node) in
                YGNodeStyleSetPositionType(node, .absolute)
                YGNodeStyleSetPosition(node, .left, 0)
                YGNodeStyleSetPosition(node, .top, 0)
                YGNodeStyleSetWidth(node, 10)
            }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 10, height: 4), withIntrinsicContentSize: CGSize(width: UIView.noIntrinsicMetric, height: 4))
        }

        it("testDoesNotOverrideDimensionStyleWithSuggestedDimensions") {
            _withShadowView(configBlock: { (node) in
                YGNodeStyleSetPositionType(node, .absolute)
                YGNodeStyleSetPosition(node, .left, 0)
                YGNodeStyleSetPosition(node, .top, 0)
                YGNodeStyleSetWidth(node, 10)
                YGNodeStyleSetHeight(node, 10)
            }, assertRelativeLayout: CGRect(x: 0, y: 0, width: 10, height: 10), withIntrinsicContentSize: CGSize(width: 3, height: 4))
        }

        it("testDoesNotAssignSuggestedDimensionsWhenStyledWithFlexAttribute") {
            let parentWidth = YGNodeStyleGetWidth(parentView?.yogaNode).value
            let parentHeight = YGNodeStyleGetHeight(parentView?.yogaNode).value
            _withShadowView(configBlock: { (node) in
                YGNodeStyleSetFlex(node, 1)
            }, assertRelativeLayout: CGRect(x: 0, y: 0, width: CGFloat(parentWidth), height: CGFloat(parentHeight)), withIntrinsicContentSize: CGSize(width: 3, height: 4))
        }
    }
}
