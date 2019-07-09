//
//  ViewController.swift
//  SMDTC
//
//  Created by Aniket on 11/17/17.
//  Copyright © 2017 Aniket. All rights reserved.
//
import UIKit
import GoogleMobileVision

class ViewController: UIViewController, FrameExtractorDelegate {
    
    @IBOutlet weak var lblSmiling: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var newView = UIView()
    private let ssQ = DispatchQueue(label: "process queue")
    var frameExtractor: FrameExtractor!
    var faceDetector: GMVDetector?
    var faces = [GMVFaceFeature]()
    var imgIsProcessing = false
    var sessionCountToClr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        self.faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: [GMVDetectorFaceLandmarkType: GMVDetectorFaceLandmark.all.rawValue,
                                                                               GMVDetectorFaceClassificationType: GMVDetectorFaceClassification.all.rawValue,
                                                                               GMVDetectorFaceMinSize: 0.3,
                                                                               GMVDetectorFaceTrackingEnabled: true])
    }
    
    @IBAction func flipButton(_ sender: UIButton) {
        frameExtractor.flipCamera()
    }
    
    func captured(image: UIImage) {
        DispatchQueue.main.async {
            self.processImage(image: image)
            self.imageView.image = image
        }
    }
    
    func processImage(image: UIImage) {
        if imgIsProcessing {
            return
        }
        
        imgIsProcessing = true
        ssQ.async { [unowned self] in
               self.faces = self.faceDetector!.features(in: image, options: nil) as! [GMVFaceFeature]
                DispatchQueue.main.async {
                    if self.faces.count > 0 {
                        for face in self.faces {
                            let rect = CGRect(x: face.bounds.minX, y: face.bounds.minY+100, width: face.bounds.size.width, height: face.bounds.size.height)
                            
                            self.drawFaceIndicator(rect: rect)
                            self.lblSmiling.text = String(format: "%.3f", face.smilingProbability)
                        }
                        self.sessionCountToClr = 0
                    }
                    else {
                        if self.sessionCountToClr == 30 {
                            self.newView.removeFromSuperview()
                            self.lblSmiling.text = "0.0"
                            self.sessionCountToClr = 0
                        } else {
                            self.sessionCountToClr+=1
                        }
                    }
                    self.imgIsProcessing = false
                }
            self.faces = []
        }
    }
    
    func drawFaceIndicator(rect: CGRect) {
            newView.removeFromSuperview()
            newView = UIView(frame: rect)
            newView.layer.cornerRadius = 10;
            newView.alpha = 0.3
            newView.layer.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            newView.layer.borderWidth = 4
            self.view.addSubview(newView)
    }
}
