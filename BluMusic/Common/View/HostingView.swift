//
//  HostingView.swift
//  BluMusic
//
//  Created by Muhammad M. Munir on 18/05/24.
//

import UIKit
import SwiftUI

final class HostingView<T: View>: UIView {

    private(set) var hostingController: UIHostingController<T>

    var rootView: T {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    init(rootView: T, frame: CGRect = .zero) {
        hostingController = UIHostingController(rootView: rootView)

        super.init(frame: frame)

        backgroundColor = .clear
        hostingController.view.backgroundColor = backgroundColor
        hostingController.view.frame = self.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
