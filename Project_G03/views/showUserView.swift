//
//  showUserView.swift
//  Project_G03
//
//  Created by user241431 on 7/4/23.
//

import SwiftUI

struct showUserView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @EnvironmentObject var storageHelper: FirebaseStorageController
    @Binding var rootScreen: Int
    var userInfo: UserInfo
    
//    func getDate(dat: String) -> Date?{
//        let dateFormatter  = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
//        return dateFormatter.date(from: dat)
//    }
    
//    func findClosestEvent(){
//        let dates = [Date]()
//        let currentDate = Date()
//        var closeMiliseconds = Int64(currentDate.timeIntervalSince1970*1000)
//        var index = 0
//        print("friendEventList \(dbHelper.friendEventList.count)")
//        for i in dbHelper.friendEventList{
//            print(i.date)
//            let eventDate = getDate(dat: i.date)
//            print(eventDate?.description)
//        }
//    }
    
    var body: some View {

        VStack{
            Text("User Profile").font(.title)
            userProfile
            Spacer()
        }
    }
    
    private var userProfile: some View{
        VStack{
            HStack{
                if let userIcon = storageHelper.userIcon{
                    Image(uiImage: userIcon)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 200, height: 200)
                }else{
                    Image("default_icon").resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading){
                    Text("\(userInfo.firstName) \(userInfo.lastName)").font(.system(size: 36, weight: .bold)).foregroundColor(.gray).padding([.bottom])
                    Text("I am attending \(userInfo.eventAttended) events").frame(alignment: .leading).padding([.bottom])
                    Button{
                        dbHelper.addToFriendList(friendEmail: userInfo.email)
                    }label: {
                        HStack{
                            Spacer()
                            Text("Add Friend").font(.system(size: 16, weight: .bold))
                            Spacer()
                        }.foregroundColor(.white)
                            .padding(.vertical)
                            .background(.blue)
                            .shadow(radius: 5)
                    }
                }.offset(x:-10)
            }.onAppear{
                storageHelper.downloadIcon(email: userInfo.email)
                dbHelper.getFriendEvent(email: userInfo.email)
            }
            VStack(alignment: .leading){
                Text("\(userInfo.firstName) \(userInfo.lastName)'s Next Event: ").font(.system(size: 24, weight: .bold)).foregroundColor(.gray).padding([.bottom],5).offset(x: 20)
                if !dbHelper.friendEventList.isEmpty{
                    List{
                        ForEach(dbHelper.friendEventList, id: \.self){ event in
                            NavigationLink{
                                eventDetailsView(rootScreen: $rootScreen, event: event).environmentObject(authHelper).environmentObject(dbHelper)
                            }label: {
                                VStack{
                                    Text("\(event.title)")
                                    Text("\(event.date)")
                                    Text("\(event.address)")
                                    ForEach(event.friendAlsoAttend, id: \.self){ friend in
                                        Text("\(friend.firstName) are also attending")
                                    }
                                }
                            }
                        }
                    }.scrollContentBackground(.hidden)
                }
                
            }
        }
        
    }
}

//struct showUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        showUserView()
//    }
//}
