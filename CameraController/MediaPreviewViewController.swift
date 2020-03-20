//
//  MediaPreviewViewController.swift
//  CameraController
//
//  Created by Артём Зайцев on 18.03.2020.
//  Copyright © 2020 Артём Зайцев. All rights reserved.
//

import UIKit
import AVFoundation


class MediaPreviewViewController: UIViewController {
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var itemURL: URL
    
    var buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 16.0
        return sv
    }()
    
    var buttonCancel: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15.0)
        b.backgroundColor = .white
        b.layer.masksToBounds = true
        return b
    }()
    
    var buttonAccept: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Post it!", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15.0)
        b.backgroundColor = .white
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(accept), for: .touchUpInside)
        return b
    }()
    
    var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Almost there!"
        l.textColor = .white
        return l
    }()
    
    init(itemURL: URL) {
        self.itemURL = itemURL
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        view.backgroundColor = .black
        
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(playerLayer!, at: 0)
        
        view.addSubview(buttonsStackView)
        view.addSubview(label)
        
        buttonsStackView.addArrangedSubview(buttonCancel)
        buttonsStackView.addArrangedSubview(buttonAccept)
        
        buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.0).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0).isActive = true
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16.0).isActive = true
        
        buttonCancel.sizeToFit()
        buttonAccept.sizeToFit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        buttonCancel.layer.cornerRadius = buttonCancel.bounds.height / 2.0
        buttonAccept.layer.cornerRadius = buttonAccept.bounds.height / 2.0
        
        playerLayer?.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let pi = AVPlayerItem(url: itemURL)
        play(playerItem: pi)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupNavigationBar() {
        let backImage = UIImage(named: "icon_back_white_20")?.withRenderingMode(.alwaysOriginal)
        let closeImage = UIImage(named: "icon_close_white_20")?.withRenderingMode(.alwaysOriginal)
        
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(pop))
        let closeButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(close))
        

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func close() {
        print("close")
    }
    
    @objc func accept() {
        print("accept")
    }
    
    func play(playerItem: AVPlayerItem) {
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
}
