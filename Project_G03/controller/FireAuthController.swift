//
//  File.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import Foundation
import FirebaseAuth

class FireAuthController : ObservableObject{
    
    var errM = ""
    
    //using inbuilt User object provided by FirebaseAuth
    @Published var user : User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var isLoginSuccessful = false
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else{
                //no change in user's auth state
                return
            }
            
            //user's auth state has changed ; update the user object
            self.user = user
        }
    }
    
    func signUp(email: String, password : String, withCompletion completion: @escaping (Bool, String) -> Void){
        Auth.auth().createUser(withEmail : email, password: password){ authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while signing up user : \(error)")
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = false
                    let e = error as? NSError
                    self.errM = e!.localizedDescription
                    completion(self.isLoginSuccessful, self.errM)
                    
                    
                }
                
                return
            }
            
            print(#function, "AuthResult : \(result)")
            
            switch(authResult){
            case .none:
                print(#function, "Unable to create account")
                DispatchQueue.main.async {
                    self.isLoginSuccessful = false
                    self.errM = "Unable to create account"
                    completion(self.isLoginSuccessful, self.errM)
                }
            case .some(_):
                print(#function, "Successfully created user account")
                
                self.user = authResult?.user
                //save the email in the UserDefaults
                UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = true
                    self.errM = ""
                    completion(self.isLoginSuccessful, self.errM)
                }
            }
            
        }
        
    }
    
    func signIn(email: String, password : String, withCompletion completion: @escaping (Bool, String) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password){authResult, error in
            guard let result = authResult else{
                print(#function, "Error while signing in user : \(error)")
                
//                if let err = error{
//                    let e = err as NSError
//                    switch e.code{
//                    case AuthErrorCode.wrongPassword.rawValue:
//                        print("invalid email or password")
//                    case AuthErrorCode.invalidEmail.rawValue:
//                        print("invalid email or password")
//                    default:
//                        print(e.localizedDescription)
//                    }
//                }
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = false
                    let e = error as? NSError
                    self.errM = e!.localizedDescription
                    completion(self.isLoginSuccessful, self.errM)
                    
                    
                }
                return
            }
            
            print(#function, "AuthResult : \(result)")
            
            switch(authResult){
            case .none:
                print(#function, "Unable to find user account")
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = false
                    let e = error as? NSError
                    self.errM = "Unable to find user account"
                    completion(self.isLoginSuccessful, self.errM)
                }
                
            case .some(_):
                print(#function, "Login Successful")
                
                self.user = authResult?.user
                //save the email in the UserDefaults
                UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
                
                print(#function, "user email : \(self.user?.email)")
                print(#function, "user displayName : \(self.user?.displayName)")
                print(#function, "user isEmailVerified : \(self.user?.isEmailVerified)")
                print(#function, "user phoneNumber : \(self.user?.phoneNumber)")
                
                DispatchQueue.main.async {
                    self.isLoginSuccessful = true
                    self.errM = ""
                    completion(self.isLoginSuccessful, self.errM)
                }
            }
        }
        
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "KEY_EMAIL")
        }catch let err as NSError{
            print(#function, "Unable to sign out : \(err)")
        }
    }
}

