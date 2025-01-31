//
//  AppCoordinator.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 31/01/25.
//

import UIKit

class AppCoordinator {
    var window: UIWindow
    var navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let welcomeVC = WelcomeView()
        welcomeVC.coordinator = self
        navigationController.viewControllers = [welcomeVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func goToMapView() {
        let mapCoordinator = MapCoordinator(navigationController: navigationController)
        mapCoordinator.start()
    }
}
import Foundation
