//
//  ComposeViewController.swift
//  333
//
//  Created by Sarah Zhou on 4/3/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import ReachabilitySwift

protocol ComposeViewControllerDelegate {
    func didComposePost()
}

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // state 1: compose post is text only
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    // state 2: compose post has a photo added
    @IBOutlet weak var photoAddedView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var countLabel2: UILabel!
    @IBOutlet weak var sendButton2: UIButton!
    @IBOutlet weak var darkenView: UIView!
    
    var delegate: ComposeViewControllerDelegate?
    let r = Reachability()!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: Any) {
        photoAddedView.isHidden = true
        pickedImage.image = nil
        captionTextView.text = defaultCaption
    }
    
    var captionPosition: CGFloat!
    var keyboardHeight = 300 as CGFloat
    let imagePicker = UIImagePickerController()
    var defaultPost = "What's on your mind?"
    var defaultCaption = "Add a caption ..."
    
    @IBAction func cameraRoll(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.resignFirstResponder()
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func camera(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        self.resignFirstResponder()
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        if r.currentReachabilityStatus == .notReachable {
            Toaster.makeToastTop(self.postTextView, "No Internet Connection.")
        } else if postTextView.text.characters.count != 0 {
            let user_id = UIDevice.current.identifierForVendor!.uuidString
            Networking.createPost(text: postTextView.text, image: nil, user_id: user_id, lat: Location.sharedInstance.lat, long: Location.sharedInstance.long)
            if let d = self.delegate {
                d.didComposePost()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sendPhotoPost(_ sender: Any) {
        if r.currentReachabilityStatus == .notReachable {
            Toaster.makeToastTop(self.infoView, "No Internet Connection.")
        } else {
            if captionTextView.text == defaultCaption {
                captionTextView.text = ""
            }
            let user_id = UIDevice.current.identifierForVendor!.uuidString
        
            Networking.createPost(text: captionTextView.text, image: pickedImage.image, user_id: user_id, lat: Location.sharedInstance.lat, long: Location.sharedInstance.long)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        postTextView.delegate = self
        postTextView.text = defaultPost
        postTextView.textColor = UIColor.lightGray
        
        captionTextView.delegate = self
        captionTextView.text = defaultCaption
        captionTextView.textColor = UIColor.lightGray
        
        captionPosition = captionTextView.frame.origin.y
        
        countLabel.text = "200"
        countLabel.textColor = UIColor.clouds()
        countLabel2.text = "200"
        countLabel2.textColor = UIColor.clouds()
        
        photoAddedView.isHidden = true
        darkenView.isHidden = true
        
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
                if photoAddedView.isHidden == false { textView.text = defaultCaption }
                else { textView.text = defaultPost }
                textView.textColor = UIColor.lightGray
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultPost {
            textView.textColor = UIColor.darkGray
            textView.text = ""
        } else if textView.text == defaultCaption {
            textView.textColor = UIColor.clouds()
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
            if postTextView.text != "" && postTextView.text != defaultPost {
                captionTextView.text = postTextView.text
                captionTextView.textColor = UIColor.clouds()
                countLabel2.text = "\(200 - captionTextView.text.characters.count)"
                if captionTextView.text.characters.count > 0 {
                    sendButton2.setTitleColor(UIColor.clouds(), for: .normal)
                }
            } else {
                postTextView.text = defaultPost
            }
        }
        dismiss(animated: true, completion: nil)
        if photoAddedView.isHidden == true {
            postTextView.becomeFirstResponder()
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        
        if photoAddedView.isHidden == false {
            captionTextView.frame.origin.y = photoAddedView.frame.height - infoView.frame.origin.y - keyboardHeight - captionTextView.frame.height
            darkenView.isHidden = false
            darkenView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        } else {
            cameraButton.frame.origin.y = self.view.frame.height - keyboardHeight - cameraButton.frame.height - 8
            photoButton.frame.origin.y = self.view.frame.height - keyboardHeight - photoButton.frame.height - 8
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if photoAddedView.isHidden == false {
            captionTextView.frame.origin.y = captionPosition
            darkenView.isHidden = true
        } else {
            cameraButton.frame.origin.y = self.view.frame.height - cameraButton.frame.height - 16
            photoButton.frame.origin.y = self.view.frame.height - photoButton.frame.height - 16
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    } */

}
