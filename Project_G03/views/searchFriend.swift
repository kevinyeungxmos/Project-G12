//
//  searchFriend.swift
//  Project_G03
//
//  Created by user241431 on 7/4/23.
//

import SwiftUI

struct searchFriend: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @Binding var rootScreen: Int
    @State private var nameOrEmail: String = ""
    
    
    
    var body: some View {
        VStack{
            Text("Search Friend").font(.title)
            TextField("Search by name", text: self.$nameOrEmail).padding().border(.pink, width: 3).padding().autocapitalization(.none)
                .onChange(of: nameOrEmail){newValue in
                    print("name changed \(newValue)")
                    dbHelper.searchFriend(nameOrEmail: self.nameOrEmail)
                }
                
            List{
                ForEach(dbHelper.searchList.enumerated().map({$0}), id: \.element.self){
                    index, friend in
                    NavigationLink{
                        showUserView()
                    }label: {
                        Text("\(friend.firstName) \(friend.lastName)")
                        Text(friend.email)
                    }
                }
            }
            Spacer()
        }
       
    }
}

//struct searchFriend_Previews: PreviewProvider {
//    static var previews: some View {
//        searchFriend()
//    }
//}
