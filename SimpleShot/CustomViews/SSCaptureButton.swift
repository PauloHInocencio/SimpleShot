//
//  SSCaptureButton.swift
//  SimpleShot
//
//  Created by Paulo Inocencio on 29/12/20.
//

import UIKit

class SSCaptureButton: UIButton {

    init(type:SSCaptureButtonType) {
        super.init(frame: .zero)
        configure()
        setButtonType(type)
    }
    
    func setButtonType(_ type:SSCaptureButtonType) {
        self.setImage(UIImage(named: type.rawValue), for: .normal)
    }
    
    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleToFill
        self.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SSCaptureButton {
    enum SSCaptureButtonType:String {
        case photo = "photoButton"
        case video = "videoButton"
    }
}
