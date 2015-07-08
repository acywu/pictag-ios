//
//  cameraViewController.swift
//  ParseStarterProject
//
//  Created by Alex Wu on 30/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse
import AVFoundation


class cameraViewController: UIViewController{
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var capturedImage: UIImageView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var tagTextBox: UITextField!
    
    @IBOutlet weak var tagView: UIView!
    
    @IBOutlet weak var tagScrollView: UIScrollView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let compressquality = 0.5
    var tagsArray:[String] = []
    var tagsObject:PFObject = PFObject(className: "tags")
    var phototags:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI deco
        takePhotoButton.layer.cornerRadius = 10;
        takePhotoButton.clipsToBounds = true;
      
        var btn:[UIButton] = [UIButton()]
        //btn.setTitle("Tag", forState: UIControlState.Normal)
        //btn.addTarget(self, action: "dummy", forControlEvents: UIControlEvents.TouchUpInside)
        //self.view.addSubview(btn)
        /**
        var buttons: [UIButton] = (0...4).map() { _ in
            let button = UIButton.buttonWithType(.Custom) as! UIButton
            self.view.addSubview(button)
            return button
        }**/
        loadTags()
        
    }
    
    func dummy(){
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        addTag(tagTextBox.text)
        
        tagTextBox.text = "" //clean

        
        return true
    }
    
    func loadTags(){
        
        // clean
        //self.tagView.subviews.map({ $0.removeFromSuperview() })
        self.tagScrollView.subviews.map({ $0.removeFromSuperview() })
        
        
        // init
        var xcoord:CGFloat = 10
        var ycoord:CGFloat = 10
        
        var query = PFQuery(className:"tags")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.limit = 1
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                
                if let o = objects {
                    let object: AnyObject = o[0]
                    let tagnames:[String] = object["names"] as! [String]
                    
                    for tagname in tagnames{
                        
                        var button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
                        
                        button.frame = CGRectMake(xcoord, ycoord, 50, 20)
                        //button.sizeToFit()
                        button.backgroundColor = UIColor.whiteColor()
                        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
                        button.layer.cornerRadius = 10;
                        button.clipsToBounds = true;
                        button.setTitle(tagname, forState: UIControlState.Normal)
                        button.addTarget(self, action: "btnTagged:", forControlEvents: UIControlEvents.TouchUpInside)
                        //self.view.addSubview(button)
                        //self.tagView.addSubview(button)
                        self.tagScrollView.addSubview(button)
                        println("tagname added:\(tagname)")
                        
                        xcoord += 70
                    }
                }
                


                
                if let objects = objects as? [PFObject] {
            
                    for object in objects {
                        
                        
                 

                    }
                }
            

                self.tagsObject = objects?.first as! PFObject
                

                

                
                
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    func btnTagged(sender:UIButton){
        if (sender.titleLabel!.text!.isEmpty){return}
        
        if (sender.backgroundColor == UIColor.whiteColor()){
            sender.backgroundColor = UIColor.blueColor()
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            phototags.append(sender.titleLabel!.text!)
            phototags = $.uniq(phototags)
            
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
            phototags = $.remove(phototags){
                $0 == sender.titleLabel!.text!
            }
        }
        

        
        // LOG
        println("-----")
        for tag in phototags{
            println("#TAG:\(tag)")
        }
        println("-----")
        
        
    }
    
    func addTag(tag: String){
        var query = PFQuery(className: "tags")
        query.getObjectInBackgroundWithId(tagsObject.objectId!) {
            (gameScore: PFObject?, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else {
                self.tagsObject.addUniqueObject(tag, forKey: "names")
                self.tagsObject.saveInBackground()
                self.loadTags()
            }
        }
    }
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    
    @IBAction func didPressTakePhoto(sender: AnyObject) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    self.uploadPhoto(image!)
                }
            })
        }

    }
    
    func uploadPhoto(image: UIImage){
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageFile = PFFile(name:"image.png", data:imageData)
        
        var photos = PFObject(className:"photos")
        photos["imageFile"] = imageFile
        photos["user"] = PFUser.currentUser()

        photos.addUniqueObjectsFromArray(phototags, forKey:"tags")
        photos.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("upload success")
            } else {
                // There was a problem, check error.description
                println("upload fail")
            }
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}