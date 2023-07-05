//
//  MyFriendListView.swift
//  Project_G03
//
//  Created by user241431 on 7/4/23.
//

import SwiftUI

struct MyFriendListView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var storageHelper: FirebaseStorageController
    @Binding var rootScreen: Int
    
    var body: some View {
        VStack{
            Text("My Friend").font(.title)
            List{
                if dbHelper.myFriendList.isEmpty{
                    Text("No Friend")
                }
                else{
                    ForEach(dbHelper.myFriendList.enumerated().map({$0}), id: \.element.self){
                        index, friend in
                        NavigationLink{
                            showUserView(rootScreen: $rootScreen, userInfo: friend).environmentObject(authHelper).environmentObject(dbHelper).environmentObject(storageHelper)
                        }label:{
                            HStack{
                                Text("\(friend.firstName) \(friend.lastName)")
                                    .bold()
                            }
                        }
                    }.onDelete(perform: {indexSet in
                        for i in indexSet{
                            print("i: \(i)")
                            let friendToDelete = dbHelper.myFriendList[i]
                            print(friendToDelete.email)
                            dbHelper.deleteFriend(friendToDelete: friendToDelete)
                        }
                    })
                }
            }.scrollContentBackground(.hidden)
            
        }.onAppear(){
            dbHelper.getMyFriendList()
        }.overlay(removeEventButton, alignment: .bottom)
    }
    
    private var removeEventButton : some View{
        Button{
            dbHelper.deleteAllFriends()
        }label: {
            HStack{
                Spacer()
                Text("Remove All Friends").font(.system(size: 16, weight: .bold))
                Spacer()
            }.foregroundColor(.white)
                .padding(.vertical)
                .background(.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 5)
        }
    }
}

//struct MyFriendListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyFriendListView()
//    }
//}
