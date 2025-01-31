//
//  WelcomeView.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 30/01/25.
//

import UIKit

class WelcomeView: UIViewController {
    
    weak var coordinator: AppCoordinator?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bem-vindo"
        label.font = .systemFont(ofSize: 44, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    private let enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Entrar", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        enterButton.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(enterButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            
            enterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            enterButton.widthAnchor.constraint(equalToConstant: 250),
            enterButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func enterTapped() {
        coordinator?.goToMapView()
    }
}


#Preview {
    return WelcomeView()
}
