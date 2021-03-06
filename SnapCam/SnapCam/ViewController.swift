//
//  ViewController.swift
//  SnapCam
//
//  Created by Jahongir Anvarov on 10.01.2022.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
 
    var session:AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let preview = AVCaptureVideoPreviewLayer()
    private let capture:UIButton = {
    
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
        
    }()
    

    override func viewDidLoad() {
    
        super.viewDidLoad()
        view.backgroundColor = .black
        preview.backgroundColor = UIColor.systemRed.cgColor
        view.layer.addSublayer(preview)
        view.addSubview(capture)
        checkCameraPermissions()
        
        
        capture.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    
    override func viewDidLayoutSubviews() {
    
        super.viewDidLayoutSubviews()
        preview.frame = view.bounds
        
        capture.center = CGPoint(x: view.frame.size.width/2,
                                       y: view.frame.size.height-100)
        
    }
    
    private func checkCameraPermissions(){
    
        switch AVCaptureDevice.authorizationStatus(for: .video) {
    
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){
     [weak self] granted in
                guard granted else{
    
                    return
                }
                DispatchQueue.main.async {
    
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            break
        @unknown default:
            break
        }
        
    }
    private func setUpCamera(){
    
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
    
            do{
    
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input) {
    
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
    
                    session.addOutput(output)
                }
                preview.videoGravity = .resizeAspectFill
                preview.session = session
                session.startRunning()
                self.session = session
                
            }
            catch{
    
                print(error)
            }
        }
    }
    
    @objc private func didTapTakePhoto(){
    
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}
extension ViewController:AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    
        guard let data = photo.fileDataRepresentation() else {
    
            return
        }
        
        
        let image = UIImage(data: data)
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}
