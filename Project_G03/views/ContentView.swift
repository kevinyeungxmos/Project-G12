//
//  ContentView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @State private var root: RootView = .SignIn
    @State private var selectedTabIndex = 0
    
    var body: some View {
        NavigationView{
            
            TabView(selection: $selectedTabIndex){
                signInView(rootScreen: $selectedTabIndex).environmentObject(authHelper)
                    .tag(0)
                    .tabItem{
                        Label("Login", systemImage: "house")
                    }
                signUpView(rootScreen: $selectedTabIndex).environmentObject(authHelper)
                    .tag(1)
                    .tabItem{
                        Label("SignUP", systemImage: "network")
                    }
                listOfEventView(rootScreen: $selectedTabIndex).environmentObject(authHelper)
                    .tag(2)
                    .tabItem{
                        Label("Find Event", systemImage: "list.dash")
                    }
                eventDetailsView(rootScreen: $selectedTabIndex).environmentObject(authHelper)
                    .tag(3)
                    .tabItem{
                        Label("Detail", systemImage: "folder")
                    }
            }
            
//            switch root{
//            case .SignIn:
//                selectedTabIndex = 0
//            case .SignUp:
//                selectedTabIndex = 1
//            case .ListOfEvent:
//                selectedTabIndex = 2
//            case .EventDetails:
//                selectedTabIndex = 3
//            }
        }.onAppear(){
            UserDefaults.standard.removeObject(forKey: "KEY_EMAIL")
            print("contentview userdefault: ", UserDefaults.standard.string(forKey: "KEY_EMAIL"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
