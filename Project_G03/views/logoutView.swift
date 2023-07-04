//
//  logoutView.swift
//  Project_G03
//
//  Created by user241431 on 7/3/23.
//

import SwiftUI

struct LogoutView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @Binding var rootScreen: Int
    
    var body: some View {
        
        Menu{
            Button{
                print("click logout")
                authHelper.signOut()
                rootScreen = 0
            }label: {
                Text("Logout")
            }
        }label: {
            Image(systemName:"gear")
                .foregroundColor(.black)
        }
    }
}
