//
//  myEventView.swift
//  Project_G03
//
//  Created by user241431 on 7/2/23.
//

import SwiftUI
import FirebaseAuth

struct myEventView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @Binding var rootScreen: Int
    
    var body: some View {
        VStack{
            Text("My Event").font(.title)
            List{
                if dbHelper.myEventList.isEmpty{
                    Text("No event")
                }
                else{
                    ForEach(dbHelper.myEventList.enumerated().map({$0}), id: \.element.self){
                        index, event in
                        NavigationLink{
                            eventDetailsView(rootScreen: $rootScreen, event: event).environmentObject(authHelper).environmentObject(dbHelper)
                        }label:{
                            HStack{
                                Text("\(event.title)")
                                    .bold()
                            }
                        }
                    }.onDelete(perform: {indexSet in
                        for i in indexSet{
                            let eventToRemove = dbHelper.myEventList[i]
                            print(eventToRemove.id!)
                            dbHelper.removeEvent(eventToRemove: eventToRemove)
                        }
                    })
                }
            }.scrollContentBackground(.hidden)
            
        }.onAppear(){
            dbHelper.getMyEvent(email: Auth.auth().currentUser?.email ?? "")
        }.overlay(removeEventButton, alignment: .bottom)
    }
    
    private var removeEventButton : some View{
        Button{
            dbHelper.removeAllEvent()
        }label: {
            HStack{
                Spacer()
                Text("Remove All Events").font(.system(size: 16, weight: .bold))
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

//struct myEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        myEventView()
//    }
//}
