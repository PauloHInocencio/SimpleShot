//
//  VideoVC.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 20/01/21.
//

import UIKit
import AVFoundation
import Photos

class VideoPreviewVC: UIViewController {

    let header = SSSaveHeader()
    private var previewLayer: AVPlayerLayer!
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        
    }
}

// MARK: CameraVC Actions

extension VideoPreviewVC {
    
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
    func save() {
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            guard let self = self else { return }
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL!)
        }) { saved, error in
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }

        }
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
}



// MARK: VideoVC views

extension VideoPreviewVC {
    
    private func setupViews() {
        configureHeaderView()
        setupPreviewLayer()
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
    
    private func setupPreviewLayer() {
        guard let url = videoURL else { return }
        
        let player = AVPlayer(url: url)
        previewLayer = AVPlayerLayer(player: player)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, below: header.layer)
        previewLayer.player?.play()
    }
}
