//
//  ComposeViewController.swift
//  333
//
//  Created by Sarah Zhou on 4/3/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // state 1: compose post is text only
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    
    // state 2: compose post has a photo added
    @IBOutlet weak var photoAddedView: UIView!
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeImage(_ sender: Any) {
        photoAddedView.isHidden = true
        pickedImage.image = nil
    }
    
    let imagePicker = UIImagePickerController()
    
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
        Networking.createPost(text: postTextView.text, image: nil, user_id: "hallo", lat: 0, long: 0)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPhotoPost(_ sender: Any) {
        if captionTextView.text == "Add a caption ..." {
            captionTextView.text = ""
        }
        
        Networking.createPost(text: captionTextView.text, image: pickedImage.image, user_id: "hallo", lat: 0, long: 0)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        postTextView.delegate = self
        postTextView.text = ""
        postTextView.textColor = UIColor.darkGray
        postTextView.becomeFirstResponder()
        
        captionTextView.delegate = self
        captionTextView.text = "Add a caption ..."
        captionTextView.textColor = UIColor.clouds()
        captionTextView.becomeFirstResponder()
        
        countLabel.text = "200"
        countLabel.textColor = UIColor.clouds()
        
        photoAddedView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = "\(200 - textView.text.characters.count)"
        if 200 - textView.text.characters.count < 0 {
            countLabel.textColor = UIColor.red
        } else {
            countLabel.textColor = UIColor.clouds()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickedImage.image = image
            self.pickedImage.contentMode = .scaleAspectFit
            photoAddedView.isHidden = false
            if postTextView.text != "" {
                captionTextView.text = postTextView.text
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    } */

}
