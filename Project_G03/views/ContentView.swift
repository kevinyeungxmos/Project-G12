//
//  ContentView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI

struct ContentView: View {
    private var authHelper = FireAuthController()
    private var storageHelper = FirebaseStorageController()
    private var dbHelper = FirestoreController.getInstance()
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
                signUpView(rootScreen: $selectedTabIndex).environmentObject(authHelper).environmentObject(dbHelper).environmentObject(storageHelper)
                    .tag(1)
                    .tabItem{
                        Label("SignUP", systemImage: "network")
                    }
                listOfEventView(rootScreen: $selectedTabIndex).environmentObject(authHelper).environmentObject(dbHelper)
                    .tag(2)
                    .tabItem{
                        Label("Find Event", systemImage: "list.dash")
                    }
//                eventDetailsView(rootScreen: $selectedTabIndex, event: $eventDetails).environmentObject(authHelper).environmentObject(dbHelper)
//                    .tag(3)
//                    .tabItem{
//                        Label("Detail", systemImage: "folder")
//                    }
                myEventView(rootScreen: $selectedTabIndex).environmentObject(authHelper).environmentObject(dbHelper)
                    .tag(4)
                    .tabItem{
                        Label("My Event", systemImage: "folder")
                    }
                searchFriend(rootScreen: $selectedTabIndex).environmentObject(authHelper).environmentObject(dbHelper).environmentObject(storageHelper)
                    .tag(5)
                    .tabItem{
                        Label("Search Friend", systemImage: "magnifyingglass")
                    }
                MyFriendListView(rootScreen: $selectedTabIndex).environmentObject(authHelper).environmentObject(dbHelper).environmentObject(storageHelper)
                    .tag(6)
                    .tabItem{
                        Label("My Friend", systemImage: "person.circle")
                    }
            }
            .toolbar{
                if (selectedTabIndex == 2 || selectedTabIndex == 3 || selectedTabIndex == 4){
                    if let _ = UserDefaults.standard.string(forKey: "KEY_EMAIL"){
                        LogoutView(rootScreen: $selectedTabIndex).environmentObject(authHelper)
                    }
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
