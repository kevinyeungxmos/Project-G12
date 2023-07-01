//
//  signInView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI

struct signInView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @Binding var rootScreen: Int
    
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var name: String = ""
    @State private var isRemember = false
    @State private var isSecure = false
    @State private var errMessage = ""
//    @State private var gotoNextView = isLogined
    @State private var linkselection : Int? = nil
    @State private var isError = false
    
    var body: some View {
        ZStack{
            NavigationLink(destination: signUpView(rootScreen: $rootScreen).environmentObject(authHelper), tag:1, selection: self.$linkselection){}
            
            Image("wallpaper_toronto")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            VStack(){

                Text("Explore")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .bold()
                    .padding([.top, .bottom], 80)
                    .shadow(radius: 10, x: 20, y: 10)
                    .offset(y:-20)
                Spacer().frame(height: 20)
                VStack(alignment: .center, spacing: 15){
                    TextField("Email", text: self.$email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .opacity(0.9)
                        .frame(width: 300, height: 50)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    ZStack{
                        Group{
                            if isSecure{
                                TextField("Password", text: self.$password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .opacity(0.9)
                                    .frame(width: 300, height: 50)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }else{
                                SecureField("Password", text: self.$password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .opacity(0.9)
                                    .frame(width: 300, height: 50)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                        }
                        Button(action: {
                            isSecure.toggle()
                        }){
                            Image(systemName: self.isSecure ? "eye.slash" : "eye")
                                .tint(.gray)
                        }.padding(.leading, 220)
                    }
                    
                }.padding(.bottom, 20)
//                Toggle(isOn: self.$isRemember){
//                    Text("Remember Me")
//                        .foregroundColor(.black)
//                }.toggleStyle(Checkboxstyle())
//                    .padding(.bottom, 20)
                Button(action: {
                    print("username: \(self.email)")
                    print("password: \(self.password)")
                    print("isSecure: \(String(self.isSecure))")
                    print("isRemeber: \(String(self.isRemember))")
                    
                    self.authHelper.signIn(email: self.email, password: self.password, withCompletion: { isSuccessful, error in
                        if (isSuccessful){
                            //show to home screen
                            print("sign in userdefault: ", UserDefaults.standard.string(forKey: "KEY_EMAIL"))
                            self.rootScreen = 2
                            self.email = ""
                            self.password = ""
                        }else{
                            //show the alert with invalid username/password prompt
                            print(#function, "Error: \(error)")
                            self.isError = true
                            self.errMessage = error
                        }
                    })
                }){
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 30)
                        .background(.green)
                        .cornerRadius(15)
                }.alert(isPresented: self.$isError){
                    Alert(title: Text("Error"), message: Text("\(self.errMessage)"), dismissButton: .default(Text("Try Again")){

                    })
                }
                
                Button(action: {
                    self.rootScreen = 1
                }){
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 30)
                        .background(.green)
                        .cornerRadius(15)
                }.alert(isPresented: self.$isError){
                    Alert(title: Text("Error"), message: Text("\(self.errMessage)"), dismissButton: .default(Text("Try Again")){

                    })
                }
                
                Spacer()
                
            }
            
        }.onAppear(){
            print("sign in userdefault: ", UserDefaults.standard.string(forKey: "KEY_EMAIL"))
        }
    }
}

//struct signInView_Previews: PreviewProvider {
//    static var previews: some View {
//        signInView()
//    }
//}
