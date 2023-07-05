//
//  signUpView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct signUpView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var storageHelper: FirebaseStorageController
    @Binding var rootScreen: Int
    
    @State private var linkselection: Int? = nil
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isError = false
    @State private var errMessage = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var iconImage: Image?
    @State private var uiIcon: UIImage?
    
    var body: some View {
        ZStack{
            NavigationLink(destination: signUpView(rootScreen: $rootScreen).environmentObject(authHelper), tag:1, selection: self.$linkselection){}
            
            Image("wallpaper_toronto")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            VStack(){

                Text("Register a User")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .bold()
                    .padding([.top], 80)
                    .shadow(radius: 10, x: 20, y: 10)
                    .offset(y:-10)
                
                VStack{
                    PhotosPicker("Select a Photos", selection: self.$photoItem, matching: .images)
                        .foregroundColor(.white)
                        .padding()
                        .background(.green)
                        .cornerRadius(15)
                    if let iconImage{
                        iconImage.resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }else{
                        Image("default_icon").resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    }
                }.onChange(of: photoItem) { newValue in
                    Task{
                        if let data = try? await photoItem?.loadTransferable(type: Data.self){
                            if let uiImage = UIImage(data: data){
                                uiIcon = uiImage
                                iconImage = Image(uiImage: uiImage)
                                return
                            }
                        }
                        print("false")
                    }
                }
                
                VStack(alignment: .center, spacing: 15){
                    TextField("First Name", text: self.$firstName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .opacity(0.9)
                        .frame(width: 300, height: 50)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Last Name", text: self.$lastName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .opacity(0.9)
                        .frame(width: 300, height: 50)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Email", text: self.$email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .opacity(0.9)
                        .frame(width: 300, height: 50)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    Group{
                            
                        SecureField("Password", text: self.$password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .opacity(0.9)
                            .frame(width: 300, height: 50)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            
                        SecureField("Confirm Password", text: self.$confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .opacity(0.9)
                            .frame(width: 300, height: 50)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            
                    }
                    
                    
                }.padding(.bottom, 20)

                Button(action: {
                    print("username: \(self.email)")
                    print("password: \(self.password)")
                    print("confirm password: \(self.confirmPassword)")
                    
                    if (self.password != self.confirmPassword){
                        self.isError = true
                        self.errMessage = "password confirm Password don't match"
                    }else if (self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty){
                        self.isError = true
                        self.errMessage = "email and password cannot be empty"
                    }else{
                        self.authHelper.signUp(email: self.email, password: self.password, withCompletion: { isSuccessful, error in
                            if (isSuccessful){
                                //show to home screen
                                storageHelper.uploadIcon(email: self.email, uiIcon: uiIcon)
                                let newUser = UserInfo(firstName: self.firstName, lastName: self.lastName, email: self.email, iconUrl: "\(self.email)/\(self.email)_icon.jpg")
                                dbHelper.insertUser(newUser: newUser)
                                self.isError = false
                                self.rootScreen = 2
                                self.email = ""
                                self.password = ""
                                self.firstName = ""
                                self.lastName = ""
                                self.confirmPassword = ""
                                self.iconImage = nil
                                self.uiIcon = nil
                                
                            }else{
                                //show the alert with invalid username/password prompt
                                print(#function, "Error: \(error)")
                                self.isError = true
                                self.errMessage = error
                            }
                        })
                    }
                }){
                    Text("Create")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 30)
                        .background(.blue)
                        .cornerRadius(15)
                }.alert(isPresented: self.$isError){
                    Alert(title: Text("Error"), message: Text("\(self.errMessage)"), dismissButton: .default(Text("Try Again")){

                    })
                }
                
                Spacer()
                
            }
            
        }.offset(y:-35)
            .onAppear(){
                print("signup userdefault: ", UserDefaults.standard.string(forKey: "KEY_EMAIL"))
            }
    }
}

//struct signUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        signUpView()
//    }
//}
