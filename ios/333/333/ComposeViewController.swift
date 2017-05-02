//
//  ComposeViewController.swift
//  333
//
//  Created by Sarah Zhou on 4/3/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import CoreLocation

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate {

    // state 1: compose post is text only
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    // state 2: compose post has a photo added
    @IBOutlet weak var photoAddedView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var countLabel2: UILabel!
    @IBOutlet weak var sendButton2: UIButton!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: Any) {
        photoAddedView.isHidden = true
        pickedImage.image = nil
        postTextView.becomeFirstResponder()
    }
    
    var captionPosition: CGFloat!
    var keyboardHeight = 300 as CGFloat
    let imagePicker = UIImagePickerController()
    var defaultCaption = "Add a caption ..."
    
    @IBAction func cameraRoll(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func camera(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        if postTextView.text.characters.count != 0 {
            Networking.createPost(text: postTextView.text, image: nil, user_id: "hallo", lat: Float(lat), long: Float(long))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sendPhotoPost(_ sender: Any) {
        if captionTextView.text == defaultCaption {
            captionTextView.text = ""
        }
        Networking.createPost(text: captionTextView.text, image: pickedImage.image, user_id: "hallo", lat: Float(lat), long: Float(long))
        self.dismiss(animated: true, completion: nil)
    }
    
    let locationManager = CLLocationManager()
    var lat: CLLocationDegrees! = 0
    var long: CLLocationDegrees! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            lat = locationManager.location!.coordinate.latitude
            long = locationManager.location!.coordinate.longitude
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        postTextView.delegate = self
        postTextView.text = ""
        postTextView.textColor = UIColor.darkGray
        postTextView.becomeFirstResponder()
        
        captionTextView.delegate = self
        captionTextView.text = defaultCaption
        captionTextView.textColor = UIColor.clouds()
        captionTextView.becomeFirstResponder()
        
        captionPosition = captionTextView.frame.origin.y
        
        countLabel.text = "200"
        countLabel.textColor = UIColor.clouds()
        countLabel2.text = "200"
        countLabel2.textColor = UIColor.clouds()
        
        photoAddedView.isHidden = true
        
        sendButton.setTitleColor(UIColor.lightGray, for: .normal)
        sendButton2.setTitleColor(UIColor.lightGray, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // hides text views
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            if textView.text == "" {
                textView.text = defaultCaption
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultCaption {
            textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(200 - textView.text.characters.count)"
        countLabel2.text = countLabel.text
        
        if 200 - textView.text.characters.count < 0 {
            countLabel.textColor = UIColor.red
            countLabel2.textColor = UIColor.red
        } else {
            countLabel.textColor = UIColor.clouds()
            countLabel2.textColor = UIColor.clouds()
        }
        
        if textView.text.characters.count == 0 {
            sendButton.setTitleColor(UIColor.lightGray, for: .normal)
            sendButton2.setTitleColor(UIColor.lightGray, for: .normal)
        } else {
            sendButton.setTitleColor(UIColor.clouds(), for: .normal)
            sendButton2.setTitleColor(UIColor.clouds(), for: .normal)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickedImage.image = image
            self.pickedImage.contentMode = .scaleAspectFit
            photoAddedView.isHidden = false
            if postTextView.text != "" {
                captionTextView.text = postTextView.text
                countLabel2.text = "\(200 - captionTextView.text.characters.count)"
                if captionTextView.text.characters.count > 0 {
                    sendButton2.setTitleColor(UIColor.clouds(), for: .normal)
                }
            }
        }
        dismiss(animated: true, completion: nil)
        if photoAddedView.isHidden == true {
            postTextView.becomeFirstResponder()
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        if photoAddedView.isHidden == false {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
            }
            captionTextView.frame.origin.y = photoAddedView.frame.height - infoView.frame.origin.y - keyboardHeight - captionTextView.frame.height
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if photoAddedView.isHidden == false {
            captionTextView.frame.origin.y = captionPosition
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    } */

}
