//
//  ViewController.swift
//  CameraController
//
//  Created by Артём Зайцев on 18.03.2020.
//  Copyright © 2020 Артём Зайцев. All rights reserved.
//

import UIKit
import MobileCoreServices


let kButtonRadius: CGFloat = 32.0


class MediaCaptureViewController: UIViewController {
    let cameraController = CameraController()
    
    var captureButton: CaptureButton = {
        let b = CaptureButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleCapturePressed), for: .touchUpInside)
        return b
    }()
    
    var pickMediaButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "icon_media_library_32"), for: .normal)
        b.addTarget(self, action: #selector(MediaCaptureViewController.handlePickMedia), for: .touchUpInside)
        return b
    }()
    
    var swapCameraButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "icon_swap_camera_32"), for: .normal)
        b.addTarget(self, action: #selector(MediaCaptureViewController.handleSwapCamera), for: .touchUpInside)
        return b
    }()
    
    var labelsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 4.0
        sv.alignment = .center
        return sv
    }()
    
    var firstLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.text = "Just take a video!"
        l.font = .systemFont(ofSize: 17.0, weight: .bold)
        return l
    }()
    
    var secondLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.text = "The world is waiting for you!"
        return l
    }()
    
    let imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .photoLibrary
        ip.mediaTypes = [(kUTTypeMovie as String)]
        ip.allowsEditing = true
        return ip
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        imagePicker.delegate = self
        
        view.backgroundColor = .black
        
        view.addSubview(captureButton)
        view.addSubview(pickMediaButton)
        view.addSubview(swapCameraButton)
        view.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(firstLabel)
        labelsStackView.addArrangedSubview(secondLabel)
        
        captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48.0).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        pickMediaButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        pickMediaButton.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor, constant: -48.0).isActive = true
        
        swapCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        swapCameraButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 48.0).isActive = true
        
        labelsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        labelsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        labelsStackView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -48.0).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureCameraController()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
        let closeImage = UIImage(named: "icon_close_white_20")?.withRenderingMode(.alwaysOriginal)
        let closeButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(close))

        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func close() {
        print("close")
    }
    
    func configureCameraController() {
        cameraController.prepare { (error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.view)
        }
    }
    
    @objc func handleCapturePressed() {
        if cameraController.isRecording {
            stopVideoCapture()
        } else {
            startVideoCapture()
        }
    }
    
    @objc func handlePickMedia() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleSwapCamera() {
        do {
            try cameraController.swapCamera()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startVideoCapture() {
        do {
            captureButton.animateStartCapture()
            try cameraController.captureVideo { (url) in
                self.captureButton.animateStopCapture()

                
                let mpvc = MediaPreviewViewController(itemURL: url)
                self.navigationController?.pushViewController(mpvc, animated: true)

                // move to next vc
                print(url)
            }
        } catch {
            captureButton.animateStopCapture()
            print(error.localizedDescription)
        }
    }
    
    func stopVideoCapture() {
        captureButton.animateStopCapture()
        try? cameraController.stopCaptureVideo()
    }
}


extension MediaCaptureViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let type = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            return
        }
        guard type == (kUTTypeMovie as String) else {
            return
        }
        guard let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
           return
        }

        imagePicker.dismiss(animated: true) {
            let mpvc = MediaPreviewViewController(itemURL: mediaUrl)
            self.present(mpvc, animated: true, completion: nil)
        }
    }
}


extension MediaCaptureViewController: UINavigationControllerDelegate {}
