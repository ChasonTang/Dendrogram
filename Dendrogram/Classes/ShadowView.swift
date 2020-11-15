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

struct ShadowView {

    /// Yoga Config which will be used to create `yogaNode` property.
    /// Override in subclass to enable special Yoga features.
    /// Defaults to suitable to current device configuration.
    ///
    /// - Returns: YGConfigRef
    static func yogaConfig() -> YGConfigRef {
        globalYogaConfig.yogaConfig
    }

    func insertSubview(_ view: ShadowView, at index: Int) {
        // TODO(唐佳诚): 插入 yogaNode
    }
}
