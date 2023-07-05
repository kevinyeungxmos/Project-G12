//
//  FirebaseStorageController.swift
//  Project_G03
//
//  Created by user241431 on 7/4/23.
//

import Foundation
import FirebaseStorage
import PhotosUI
import SwiftUI

class FirebaseStorageController: ObservableObject{
    
    private var storageRef = Storage.storage().reference()
    
    @Published var userIcon: UIImage? = nil
    
    func uploadIcon(email: String, uiIcon: UIImage?){
        
        if let userIcon = uiIcon{
            let iconI = userIcon.jpegData(compressionQuality: 0.6)
            //prevent nil
            guard iconI != nil else{
                print("cannot convert to jpeg")
                return
            }
            let fileRef = storageRef.child("\(email)/\(email)_icon.jpg")
            
            let uploadT = fileRef.putData(iconI!) { data, error in
                if data != nil && error == nil{
                    print("Uploaded Icon")
                }else{
                    print(error)
                }
            }
        }else{
            print("user doesn't set an icon")
        }
    }
    
    func downloadIcon(email: String) {
        storageRef.child("\(email)/\(email)_icon.jpg").getData(maxSize: 5*1024*1024){
            data, error in
            if error != nil{
                print("\(String(describing: error))")
                self.userIcon = nil
            }else{
                self.userIcon = UIImage(data: data!)
            }
        }
    }
}
