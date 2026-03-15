//
//  SwipeBackEnabler.swift
//  stoury
//
//  Created by Codex on 14/03/26.
//

import SwiftUI
import UIKit

struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let navigationController = uiViewController.navigationController else { return }
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = nil
        }
    }

    private final class Controller: UIViewController {}
}

extension View {
    func enableSwipeBack() -> some View {
        background(SwipeBackEnabler())
    }
}
