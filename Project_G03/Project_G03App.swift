//
//  Project_G03App.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct Project_G03App: App {
    let authHelper = FireAuthController()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authHelper)
        }
    }
}
