//
//  Networking.swift
//  333
//
//  Created by Sarah Zhou on 4/8/17.
//  Copyright © 2017 333. All rights reserved.
//

import UIKit
import Alamofire

class Networking {
    
    static let baseurl = "https://robin333.herokuapp.com"
    static let dateFormatter = DateFormatter()
    static let niceDateFormatter: DateFormatter? = DateFormatter()

    static func stringToData(s:String) -> Data {
        return s.data(using: String.Encoding.utf8)!
    }
    static func floatToData(f:Float) -> Data {
        return stringToData(s: String(describing: f))
    }

    //Create a new post with the specified parameters.
    static func createPost(text:String?, image:UIImage?, user_id:String, lat:Float, long:Float) {
        var request = try! URLRequest(url: baseurl.asURL().appendingPathComponent("/api/posts"))
        request.httpMethod = HTTPMethod.post.rawValue
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if image != nil {
                    guard let imageData = UIImageJPEGRepresentation(image!, 0.5) else {
                        print("Could not get JPEG representation of UIImage")
                        return
                    }
                    multipartFormData.append(imageData,
                                             withName: "img",
                                             fileName: "img.jpg",
                                             mimeType: "image/jpeg")
                }

                if (text != nil) {
                    multipartFormData.append(stringToData(s: text!), withName: "text")
                }
                multipartFormData.append(stringToData(s: user_id), withName: "user_id")
                multipartFormData.append(floatToData(f: lat), withName: "lat")
                multipartFormData.append(floatToData(f: long), withName: "long")
            },
            with: request,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate()
                    upload.responseJSON { response in
                        guard response.result.isSuccess else {
                            print("Error while creating post: \(String(describing: response.result.error))")
                            return
                        }

                        guard let responseJSON = response.result.value as? [String: Any] else {
                            print("Invalid response received when creating post")
                            return
                        }
                        print("Successfully created post \(String(describing: responseJSON["post_id"]))")
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    //Get all new posts and run the completion handler if successful.
    static func getPosts(completion: @escaping ([Dictionary<String, Any>]) -> Void) {
        
        Alamofire.request("\(baseurl)/api/posts/new?lat=0.25&long=0").responseJSON { response in
            
            if let JSON = response.result.value {
                completion(JSON as! [Dictionary<String, Any>])
            }
            
            else {
                print("ERROR")
            }
        }
    }
    
    //Create a new vote with the specified parameters.
    static func createVote(user_id:String, object_id:String, up:Bool) {
        let parameters: Parameters = [
            "user_id": user_id,
            "object_id": object_id,
            "up": up
        ]
        
        Alamofire.request("\(baseurl)/api/votes", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        })
    }
    
    //Create a new comment with the specified parameters.
    static func createComment(text:String, user_id:String, post_id:String) {
        let parameters: Parameters = [
            "text": text,
            "user_id": user_id,
            "post_id": post_id,
        ]
        
        Alamofire.request("\(baseurl)/api/comments", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        })
    }
    
    //Get all comments and run the completion handler if successful.
    static func getComments(post_id:String, completion: @escaping ([Dictionary<String, Any>]) -> Void) {
        
        Alamofire.request("\(baseurl)/api/comments/new?post_id="+post_id).responseJSON { response in
            
            if let JSON = response.result.value {
                completion(JSON as! [Dictionary<String, Any>])
            }
                
            else {
                print("ERROR")
            }
        }
    }
    
    static func initializeDateFormatter() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        niceDateFormatter!.dateFormat = "MM-dd hh:mm"
    }
}


