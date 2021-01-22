//
//  SSSaveHeader.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 29/12/20.
//

import UIKit

class SSSaveHeader: UIView {
    
    let saveButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    
    init () {
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        configureView()
        configureSaveButton()
        configureCloseButton()
    }
    
    private func configureView(){
        backgroundColor = .darkGray
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureSaveButton() {
        saveButton.titleLabel?.font = .systemFont(ofSize: 20)
        saveButton.tintColor = .label
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
    
    private func configureCloseButton() {
        closeButton.titleLabel?.font = .systemFont(ofSize: 15)
        closeButton.setImage(UIImage(named: "cross"), for: .normal)
        closeButton.tintColor = .label
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 18),
            closeButton.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
