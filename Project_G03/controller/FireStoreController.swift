//
//  FireStoreController.swift
//  Project_G03
//
//  Created by user241431 on 7/1/23.
//

import Foundation
import FirebaseFirestore

class FirestoreController : ObservableObject{
    
    @Published var myEventList = [EventInfo]()
    @Published var searchList = [UserInfo]()
    @Published var friendEventList = [EventInfo]()
    @Published var myFriendList = [UserInfo]()
    @Published var bb : [[String: Int?]] = []

    
    private let db : Firestore
    private static var shared : FirestoreController?
    
    
    private let COLLECTION = "User"
    private let SUBCOLLECTION = "UserInfo"
    private let USER_EVENT = "UserEvent"
    private let FRIEND_LIST = "FriendList"
    
    private var loggedInUserEmail : String = ""
    private var firestoreListener: ListenerRegistration?
    
    init(db : Firestore){
        self.db = db
    }
    
    //singleton instance
    static func getInstance() -> FirestoreController{
        if (self.shared == nil){
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        
        return self.shared!
    }
    
    func searchFriend(nameOrEmail:String){
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        self.searchList.removeAll()
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }else{
            do{
                try self.db.collection(COLLECTION).getDocuments(){
                    (querySnapshot, err) in
                    if let err = err{
                        print("Error getting document: \(err)")
                    }else{
                        for document in querySnapshot!.documents{
                            let userInfo = try? document.data(as: UserInfo.self)
                            if let ui = userInfo{
                                if ui.firstName.contains(nameOrEmail){
                                    if ui.email != self.loggedInUserEmail{
                                        self.searchList.append(ui)
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
                print("Cannot retrieve user info from db: \(error)")
            }
        }
    }
    
    func insertUser(newUser: UserInfo){
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION)
                    .document(self.loggedInUserEmail)
                    .setData(from: newUser)
                print("added")
            }catch let err as NSError{
                print("Unable to add user to database \(err)")
            }
        }
    }
    
    func insertEventtoUserEventList(email:String, event: EventInfo){
        //check user doc exist or not
        let docRef = self.db.collection(COLLECTION).document(email)
        docRef.getDocument{
            (document, error) in
            //check if the user exist
            if let doc = document, doc.exists{
                do{
                    try self.db.collection(self.COLLECTION).document(email)
                        .collection(self.USER_EVENT).document(String(event.id!)).getDocument(){
                            (querySnapshot, err) in
                            //check if the event exist?
                            if let d = querySnapshot, d.exists{
                                print("Event already added")
                            }else{
                                //not exist
                                //add the event to user event list
                                do{
                                    try self.db
                                        .collection(self.COLLECTION)
                                        .document(email)
                                        .collection(self.USER_EVENT)
                                        .document(String(event.id!))
                                        .setData(from: event)
                                    print("event added")
                                }catch let err as NSError{
                                    print("Unable to add event to user event list \(err)")
                                }
                                
                                // update the amount of event attended by user
                                do{
                                    var userI: UserInfo = try doc.data(as: UserInfo.self)
                                    userI.eventAttended += 1
                                    //update user information
                                    try self.db
                                        .collection(self.COLLECTION)
                                        .document(email)
                                        .updateData(["eventAttended" : userI.eventAttended]){
                                            error in
                                            if let e = error{
                                                print("Unable to update user Information: \(e)")
                                            }else{
                                                print("Update successfully")
                                            }
                                        }
                                    
                                }catch let err as NSError{
                                    print(err)
                                }
                            }
                        }
                }catch let err as NSError{
                    print(err)
                }
            }else{
                print("Document doesn't exist")
            }
        }
    }
    
    func removeEvent(eventToRemove: EventInfo){
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        guard eventToRemove.id != nil  else{
            print("Cannot remove event")
            return
        }
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }
        else{
            //remove event
            
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(USER_EVENT)
                .document(String(eventToRemove.id!)).delete{
                    error in
                    if let e = error{
                        print("Unable to remove event: \(String(describing: e))")
                    }else{
                        print("Remove event successfully")
                    }
                }
            
            //update the amount of event attended by user
            let docRef = self.db.collection(COLLECTION).document(self.loggedInUserEmail)
            docRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    do{
                        var dChange: UserInfo = try document.data(as: UserInfo.self)
                        dChange.eventAttended -= 1
                        
                        self.db
                            .collection(self.COLLECTION)
                            .document(self.loggedInUserEmail)
                            .updateData(["eventAttended" : dChange.eventAttended]){
                                error in
                                if let e = error{
                                    print("Unable to update user Information: \(e)")
                                }else{
                                    print("Update successfully")
                                }
                            }

                    }catch let err as NSError{
                        print("Cannot convert json to swift model: \(err)")
                    }
                }
            }
        }
    }
    
    func removeAllEvent(){
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }
        else{
            //remove all event
            
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(USER_EVENT)
                .getDocuments(){ [self]
                    querySnapshort, err in
                    if let err = err{
                        print("Error getting documents: \(err)")
                    } else {
                        for doc in querySnapshort!.documents{
                            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(USER_EVENT)
                                .document(doc.documentID).delete(){
                                    err in
                                    if let err = err {
                                        print("Error removing document: \(err)")
                                    } else {
                                        print("Document successfully removed")
                                    }
                                }
                        }
                    }
                }
                          
            //update the amount of event attended by user
            let docRef = self.db.collection(COLLECTION).document(self.loggedInUserEmail)
            docRef.getDocument {(document, error) in
                if let document = document, document.exists {
                    do{
                        var dChange: UserInfo = try document.data(as: UserInfo.self)
                        dChange.eventAttended = 0
                        
                        self.db
                            .collection(self.COLLECTION)
                            .document(self.loggedInUserEmail)
                            .updateData(["eventAttended" : dChange.eventAttended]){
                                error in
                                if let e = error{
                                    print("Unable to update user Information: \(e)")
                                }else{
                                    print("Update successfully")
                                }
                            }

                    }catch let err as NSError{
                        print("Cannot convert json to swift model: \(err)")
                    }
                }
            }
        }
    }

    func getMyEvent(email: String){
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        myEventList.removeAll()
        firestoreListener?.remove()
        
        if (email.isEmpty){
            print("Cannot show user's events, please login")
        }
        else{
            do{
                firestoreListener = self.db
                    .collection(COLLECTION).document(email).collection(USER_EVENT).addSnapshotListener({(querySnapshot, error) in
                        guard let snapshot = querySnapshot else{
                            print("Unable to retrieve data from db: \(String(describing: error))")
                            return
                        }
                        snapshot.documentChanges.forEach{
                            docChange in
                            
                            do {
                                let tempList : EventInfo = try docChange.document.data(as: EventInfo.self)
                                var docId = docChange.document.documentID
                                print("DocumentID: \(docId)   tempList id: \(String(describing: tempList.id))")
                                
                                if docChange.type == .added{
                                    self.myEventList.append(tempList)
                                }
                                
                                let eventIndex = self.myEventList.firstIndex(where: {($0.id == tempList.id)})
                                
                                print(eventIndex!)
                                
                                if docChange.type == .removed{
                                    if eventIndex != nil{
                                        self.myEventList.remove(at: eventIndex!)
                                    }
                                }
                                
                                if docChange.type == .modified{
                                    if eventIndex != nil{
                                        self.myEventList[eventIndex!] = tempList
                                    }
                                }
                                
                            }catch let err as NSError{
                                print("Unable to convert json file \(err.localizedDescription)")
                            }
                        }
                    })
            }
        }
    }
    
    func addToFriendList(friendEmail: String){
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (friendEmail.isEmpty && self.loggedInUserEmail.isEmpty){
            print("invalid user, please login")
        }
        else{
            do{
                try self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST)
                    .document(friendEmail).setData(["email":friendEmail])
                print("friend added")
            }catch{
                print("Error addin to frient list: \(error)")
            }
        }
    }
    
    func deleteFriend(friendToDelete: UserInfo){
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        guard friendToDelete.id != nil  else{
            print("Cannot remove event")
            return
        }
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }
        else{
            //delete friend
            
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST)
                .document(friendToDelete.email).delete{
                    error in
                    if let e = error{
                        print("Unable to delete friend: \(String(describing: e))")
                    }else{
                        print("Delete friend successfully")
                        self.getMyFriendList()
                    }
                }
            
        }
    }
    
    func deleteAllFriends(){
        
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty{
            print("user's email address not available")
        }
        else{
            //delete all friend
            
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST)
                .getDocuments(){ [self]
                    querySnapshort, err in
                    if let err = err{
                        print("Error getting documents: \(err)")
                    } else {
                        for doc in querySnapshort!.documents{
                            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST)
                                .document(doc.documentID).delete(){
                                    err in
                                    if let err = err {
                                        print("Error deleting document: \(err)")
                                    } else {
                                        print("Document successfully deleted")
                                        self.getMyFriendList()
                                    }
                                }
                        }
                    }
                }
        }
    }
    
    func getMyFriendList(){
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        self.myFriendList.removeAll()
        if (self.loggedInUserEmail.isEmpty){
            print("invalid user, please login")
        }
        else{
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST).getDocuments(){
                docs, err in
                if let err = err{
                    print("Error getting documents: \(err)")
                }
                else{
                    for doc in docs!.documents{
                        print("your friend: \(doc.documentID)")
                        self.db.collection(self.COLLECTION).document(doc.documentID).getDocument(){querySnapshort,error in
                            if let err = error{
                                print("Error of getting friend details")
                            }
                            else{
                                let temp = try? querySnapshort!.data(as: UserInfo.self)
                                print("Friend name \(String(describing: temp?.firstName)) \(String(describing: temp?.lastName))")
                                self.myFriendList.append(temp!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getFriendEvent(email: String) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        friendEventList.removeAll()
        
        if (email.isEmpty && self.loggedInUserEmail.isEmpty){
            print("Cannot show user's events, please login")
        }
        else{
            self.db.collection(COLLECTION).document(email).collection(USER_EVENT).getDocuments(){
                docs, err in
                if let err = err{
                    print("Error getting documents: \(err)")
                }else{
                    for doc in docs!.documents{
                        var temp = try? doc.data(as: EventInfo.self)
                        if temp != nil{
                            self.friendEventList.append(temp!)
                        }
                        print("read friend event from db successfully \(self.friendEventList.count)")
                    }
                }
            }
        }
    }
    
    func getAnothertFriendEvent(email: String) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
//        friendEventList.removeAll()
        
        self.bb.removeAll()
        
        if (email.isEmpty && self.loggedInUserEmail.isEmpty){
            print("Cannot show user's events, please login")
        }
        else{
            self.db.collection(COLLECTION).document(self.loggedInUserEmail).collection(FRIEND_LIST).getDocuments(){
                querySnapshot, error in
                if let err = error{
                    print("Error getting documents: \(err)")
                }else{
                    for em in querySnapshot!.documents{
                        if email != em.documentID{
                            self.db.collection(self.COLLECTION).document(em.documentID).collection(self.USER_EVENT).getDocuments(){
                                docs, err in
                                if let err = err{
                                    print("Error getting documents: \(err)")
                                }else{
                                    for doca in docs!.documents{
                                        let temp = try? doca.data(as: EventInfo.self)
                                        for docf in self.friendEventList{
                                            if temp?.id == docf.id{
                                                self.bb.append([em.documentID: temp?.id])
                                            }
                                        }
                                        print("read another friend event from db successfully")
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    
}
