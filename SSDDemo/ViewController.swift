//
//  ViewController.swift
//  SSDDemo
//
//  Created by Nicky Chan on 11/6/17.
//  Copyright © 2017 PaddlePaddle. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

typealias ImageBufferHandler = ((_ imageBuffer: CVPixelBuffer, _ timestamp: CMTime, _ outputBuffer: CVPixelBuffer?) -> ())

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoConnection: AVCaptureConnection!
    var captureDevice : AVCaptureDevice?
    
    var imageBufferHandler: ImageBufferHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh //high means high definition of video
        
        captureDevice = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.back).devices.first
        
        // setup video device input
        do {
            let videoDeviceInput: AVCaptureDeviceInput
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            
            captureSession.beginConfiguration()
            guard captureSession.canAddInput(videoDeviceInput) else {
                fatalError("CaptureSession can not add input")
            }
            captureSession.addInput(videoDeviceInput)
        }
        
        // setup preview
        let previewContainer = self.view.layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)!
        previewLayer.frame = previewContainer.bounds
        previewLayer.contentsGravity = kCAGravityResizeAspectFill
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewContainer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        
        let multiboxLayer = SSDMultiboxLayer()
        multiboxLayer.displayBoxs(with: self.fakeData())
        previewContainer.insertSublayer(multiboxLayer, at: 1)
        
        // setup video output
        do {
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            guard captureSession.canAddOutput(videoDataOutput) else {
                fatalError("CaptureSession can not add output")
            }
            captureSession.addOutput(videoDataOutput)
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.paddlepaddle.SSDDemo")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            
            videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
            
            
            captureSession.startRunning()
        }
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("didDrop")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("didOutput")
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        
        if let imageBufferHandler = imageBufferHandler, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) , connection == videoConnection
        {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            imageBufferHandler(imageBuffer, timestamp, nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("viewDidAppear");
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        print("viewDidDisappear");
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("viewWillAppear");
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("viewWillDisappear");
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fakeData() -> Array<SSDData> {
        let obj1 = SSDData()
        obj1.x = 100
        obj1.y = 100
        obj1.width = 100
        obj1.height = 100
        obj1.accuracy = 0.3
        obj1.label = "Car"
        
        let obj2 = SSDData()
        obj2.x = 200
        obj2.y = 200
        obj2.width = 100
        obj2.height = 100
        obj2.accuracy = 0.7
        obj2.label = "Cow"
        
        return [obj1, obj2]
    }
}

