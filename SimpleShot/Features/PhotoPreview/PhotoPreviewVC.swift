//
//  PhotoPreviewVC.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 29/12/20.
//

import UIKit

class PhotoPreviewVC: UIViewController {
    
    let header = SSSaveHeader()
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
    }
    
    
}

// MARK: PhotoPreviewVC Actions

extension PhotoPreviewVC {
    
    func setupActions() {
        addSaveButtonTouchUpInsideAction()
        addCloseButtonTouchUpInsideAction()
    }
    
    func addSaveButtonTouchUpInsideAction() {
        header.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
    func addCloseButtonTouchUpInsideAction() {
        header.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc
    func save() {[
        guard let imageToSave = imageView.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
}



// MARK: PhotoPreviewVC Views

extension PhotoPreviewVC {
    
    func setupViews() {
        configureImageView()
        configureHeaderView()
    }
    
    private func configureHeaderView() {
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
}
