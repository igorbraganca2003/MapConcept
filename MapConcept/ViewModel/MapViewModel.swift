//
//  MapViewModel.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 31/01/25.
//

import Foundation
import CoreLocation
import MapKit

class MapViewModel {
    
    private let locationService = LocationService()
    private let api = SPTransServices()
    private weak var mapView: MKMapView?
    
    var onAddAnnotation: ((MKPointAnnotation) -> Void)?
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onBusLocationUpdate: (([BusPositionSP]) -> Void)?
    
    // Lista de linhas de ônibus (deve ser preenchida com as informações corretas)
    var busLinesInfo: [BusLinesInfoSP] = []

    init(mapView: MKMapView) {
        self.mapView = mapView
        locationService.delegate = self
    }
    
    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }
    
    func fetchBusPosition(busNumber: String) {
        api.autenticar { success in
            guard success else {
                print("Falha na autenticação. Não foi possível buscar a localização dos ônibus.")
                return
            }

            Task {
                do {
                    let busPositions = try await self.api.getBusPositionSP(busNumber: busNumber)

                    // Aqui, vamos buscar as informações das linhas de ônibus
                    if let busLines = try? await self.api.getBusLinesInfo() {
                        self.busLinesInfo = busLines
                    }

                    DispatchQueue.main.async {
                        guard !busPositions.isEmpty else {
                            print("Nenhum ônibus encontrado para essa linha.")
                            self.onBusLocationUpdate?([])
                            return
                        }

                        self.onBusLocationUpdate?(busPositions)
                        
                        for bus in busPositions {
                            // Encontrando a linha de ônibus que corresponde ao prefixo (p)
                            if let busLineInfo = self.busLinesInfo.first(where: { $0.cl == Int(bus.p)! }) {
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = CLLocationCoordinate2D(latitude: bus.py, longitude: bus.px)
                                annotation.title = "\(busLineInfo.lt0)" // Usando o letreiro completo
                                annotation.subtitle = bus.a ? "Acessível" : "Não acessível"

                                self.onAddAnnotation?(annotation)
                            }
                        }
                        
                        if let mapView = self.mapView {
                            let currentZoom = mapView.region.span.latitudeDelta
                            if currentZoom > 0.005 {
                                let firstBus = busPositions.first!
                                let region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: firstBus.py, longitude: firstBus.px),
                                    latitudinalMeters: 500,
                                    longitudinalMeters: 500
                                )
                                mapView.setRegion(region, animated: true)
                            }
                        }
                    }
                } catch {
                    print("Erro ao buscar a localização dos ônibus:", error)
                }
            }
        }
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
