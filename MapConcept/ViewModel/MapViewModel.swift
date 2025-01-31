//
//  MapViewModel.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 31/01/25.
//

import Foundation
import CoreLocation

class MapViewModel {
    private let locationService = LocationService()
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    init() {
        locationService.delegate = self
    }

    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }
}

extension MapViewModel: LocationServiceDelegate {
    func didUpdateLocation(_ location: CLLocation) {
        onLocationUpdate?(location)
    }

    func didFailWithError(_ error: Error) {
        print("Erro de localização: \(error)")
    }
}

