//
//  ViewController.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 28/12/20.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    private let capturePreviewView = UIView()
    private let captureButton = SSCaptureButton(type: .photo)
    private var toggleCameraButton = UIButton(type: .system)
    private var segmentedControl:UISegmentedControl!
    private var isRecording = false
    
    private var currentCameraMode:CaptureMode = .photo
    private let controller = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        initPreview()
    }
    
    func initPreview() {
        controller.prepareSession {[weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            self.controller.displayPreview(on: self.capturePreviewView)
        }
    }
}

// MARK: CameraVC Views

extension CameraVC {
    func setupViews() {
        configurePreviewView()
        configurePhotoButton()
        configureToggleButton()
        configureSegmentedControl()
    }
    
    private func configurePreviewView(){
        view.addSubview(capturePreviewView)
        capturePreviewView.backgroundColor = .darkText
        capturePreviewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capturePreviewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            capturePreviewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            capturePreviewView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            capturePreviewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func configurePhotoButton() {
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -49),
            captureButton.widthAnchor.constraint(equalToConstant: 55),
            captureButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func configureToggleButton() {
        toggleCameraButton.translatesAutoresizingMaskIntoConstraints = false
        toggleCameraButton.setImage(UIImage(named: "swap-camera"), for: .normal)
        toggleCameraButton.contentMode = .scaleAspectFill
        toggleCameraButton.tintColor = .white
        view.addSubview(toggleCameraButton)
        NSLayoutConstraint.activate([
            toggleCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            toggleCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            toggleCameraButton.widthAnchor.constraint(equalToConstant: 36),
            toggleCameraButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func configureSegmentedControl() {
        let items = [UIImage(systemName: "camera"), UIImage(systemName: "video")]
        segmentedControl = UISegmentedControl(items: items as [Any])
        segmentedControl.selectedSegmentIndex = CaptureMode.photo.rawValue
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            segmentedControl.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}


// MARK: CameraVC Actions

extension CameraVC {
    
    func setupActions() {
        addCaptureButtonTouchUpInsideAction()
        addToggleButtonTouchUpInsideAction()
        addSegmentedControlValueChanged()
    }
    
    private func addToggleButtonTouchUpInsideAction() {
        toggleCameraButton.addTarget(self, action: #selector(flipOverCamera), for: .touchUpInside)
    }
    
    private func addCaptureButtonTouchUpInsideAction() {
        captureButton.addTarget(self, action: #selector(capture), for: .touchUpInside)
    }
    
    private func addSegmentedControlValueChanged() {
        segmentedControl.addTarget(self, action: #selector(changeCaptureMode), for: .valueChanged)
    }
    
    
    @objc
    func flipOverCamera() {
        controller.flipOverCamera { error in
            if let error = error {
                print(error)
                return
            }
        }
    }
    
    
    @objc
    func capture() {
        switch currentCameraMode {
            case .photo:
                takePhoto()
            case .video:
                recordVideo()
        }
    }
    
    @objc
    func changeCaptureMode() {
        if segmentedControl.selectedSegmentIndex == CaptureMode.photo.rawValue {
            currentCameraMode = .photo
            controller.changeToPhotoCapture { error in
                if let error = error {
                    print(error)
                    return
                }
            }
        } else {
            currentCameraMode = .video
            controller.changeToVideoCapture { error in
                if let error = error {
                    print(error)
                    return
                }
            }
        }
    }
    
    
    private func takePhoto() {
        controller.takePhoto { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let image):
                    let photoVC = PhotoVC()
                    photoVC.imageView.image = image
                    self.present(photoVC, animated: true)
                    
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    private func recordVideo() {
        if !isRecording {
            isRecording = true
            
            // Animate button
            captureButton.setButtonType(.video)
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: { [weak self] in
                self?.captureButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: nil)
            
            controller.startRecording()
        } else {
            isRecording = false
            
            //Animate button
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: { [weak self] in
                self?.captureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) {[weak self] _ in
                self?.captureButton.setButtonType(.photo)
                self?.captureButton.layer.removeAllAnimations()
            }
            
            controller.finishRecording { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let url):
                        let videoVC = VideoVC()
                        videoVC.videoURL = url
                        self.present(videoVC, animated: true)
                        break
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
}

extension CameraVC {
    
    public enum CaptureMode : Int {
        case photo = 0
        case video = 1
    }
}
