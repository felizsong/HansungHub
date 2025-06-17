//
//  SceneDelegate.swift
//  HansungHub
//
//  Created by 송희 on 6/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // 하단 탭 바 색상 변경
        UITabBar.appearance().tintColor = .black
        UITabBar.appearance().unselectedItemTintColor = .lightGray
        
        // 상단 화살표 커스텀
        if let backImage = UIImage(named: "icon_left") {
            let navBarAppearance = UINavigationBar.appearance()
            navBarAppearance.backIndicatorImage = backImage
            navBarAppearance.backIndicatorTransitionMaskImage = backImage
            navBarAppearance.tintColor = .black
        }

        // "Back" 텍스트 제거
        let barAppearance = UIBarButtonItem.appearance()
        barAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)


        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let userDefaults = UserDefaults.standard
        let isAutoLogin = userDefaults.bool(forKey: "autoLogin")
        let isLogIn = userDefaults.bool(forKey: "isLogIn")

        if isAutoLogin && isLogIn {
            // 자동 로그인 true면 Main으로
            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        } else {
            // 아니면 Login부터
            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        }

        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

