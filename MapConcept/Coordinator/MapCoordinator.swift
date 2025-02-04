//
//  MapCoordinator.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 31/01/25.
//

import UIKit
import MapKit

class MapCoordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let mapView = MapView()
        navigationController.pushViewController(mapView, animated: true)
    }
}
