//
//  SceneDelegate.swift
//  ecg
//
//  Created by insung on 4/7/25.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        window?.rootViewController = UIHostingController(
            rootView: SplashView()
        )
        window?.makeKeyAndVisible()
    }
}
