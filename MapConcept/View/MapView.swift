//
//  MapView.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 30/01/25.
//

import UIKit
import MapKit

class MapView: UIViewController {
    
    private var viewModel: MapViewModel!
    private var userInteractedWithMap = false
    private var hasSetInitialRegion = false
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        return map
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("IR", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        return button
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        let color = UIColor.lightGray
        let placeholder: String = "Digite o número do ônibus aqui"
        
        textField.layer.cornerRadius = 12
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.8
        textField.layer.shadowOffset = CGSize(width: 0, height: 5)
        textField.layer.shadowRadius = 30
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel = MapViewModel(mapView: mapView)
        setupBindings()
        viewModel.startUpdatingLocation()
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        mapView.delegate = self
        
        setupKeyboardToolbar()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func searchButtonTapped() {
        guard let busNumber = searchTextField.text, !busNumber.isEmpty else {
            print("Digite um número de ônibus válido")
            return
        }

        searchTextField.resignFirstResponder() 

        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.searchButton.backgroundColor = UIColor.blue
        }) { _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.searchButton.backgroundColor = UIColor.systemBlue
            }
        }

        viewModel.fetchBusPosition(busNumber: busNumber)
        searchTextField.text = ""
    }

    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.searchTextField.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
                self.searchButton.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.searchTextField.transform = .identity
            self.searchButton.transform = .identity
        }
    }
    
    @objc private func dismissKeyboard() {
        searchTextField.resignFirstResponder()
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(dismissKeyboard))

        toolbar.items = [flexSpace, doneButton]
        searchTextField.inputAccessoryView = toolbar
    }

    private func setupBindings() {
        viewModel.onLocationUpdate = { [weak self] location in
            guard let self = self else { return }
            
            if !self.hasSetInitialRegion {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                
                DispatchQueue.main.async {
                    self.mapView.setRegion(region, animated: true)
                    self.hasSetInitialRegion = true
                }
            }
        }
        
        viewModel.onAddAnnotation = { [weak self] annotation in
            DispatchQueue.main.async {
                self?.mapView.addAnnotation(annotation)
            }
        }
        
        // Aqui estamos utilizando a propriedade `busLinesInfo` da `MapViewModel` para associar os dados do ônibus.
        viewModel.onBusLocationUpdate = { [weak self] buses in
            DispatchQueue.main.async {
                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                for bus in buses {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: bus.py, longitude: bus.px)
                    
                    // Buscando a linha de ônibus correspondente para obter o lt0
                    if let busLineInfo = self?.viewModel.busLinesInfo.first(where: { $0.cl == Int(bus.p)! }) {
                        annotation.title = busLineInfo.lt0 // Utilizando lt0 da linha
                    }
                    
                    annotation.subtitle = bus.a ? "Acessível" : "Não acessível"
                    self?.mapView.addAnnotation(annotation)
                }
            }
        }
    }



    
    private func setupUI() {
        
        view.addSubview(searchButton)
        view.addSubview(searchTextField)
        view.addSubview(mapView)
        
        view.bringSubviewToFront(searchTextField)
        view.bringSubviewToFront(searchButton)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchTextField.heightAnchor.constraint(equalToConstant: 50),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            searchTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            searchButton.heightAnchor.constraint(equalToConstant: 30),
            searchButton.widthAnchor.constraint(equalToConstant: 60),
            searchButton.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: -10),
            searchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor)
        ])
    }
}


extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        userInteractedWithMap = true
    }
}


//#Preview{
//    return MapView()
//}

