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
    
    private let db : Firestore
    private static var shared : FirestoreController?
    
    
    private let COLLECTION = "User"
    private let SUBCOLLECTION = "UserInfo"
    private let USER_EVENT = "UserEvent"
    
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
            if let doc = document, doc.exists{
                
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
                                print("Unable to update user Information")
                            }else{
                                print("Update successfully")
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
        guard let id = eventToRemove.id  else{
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
                                    print("Unable to update user Information")
                                }else{
                                    print("Update successfully")
                                }
                            }

                    }catch let err as NSError{
                        print("Cannot convert json to swift model: \(err)")
                    }
                }
            }
//            do{
//                self.db.collection(COLLECTION).document(self.loggedInUserEmail).getDocument{doc,err in
//                    if let dd = doc{
//                        var dChange = try dd.data(as: UserInfo.self)
//                    }
//                }
//            }catch let err as NSError{
//                print("Unable to update user info: \(err)")
//            }
            
        }
    }

    //    func deleteEmployee(empToDelete : Employee){
    //        print(#function, "Deleting employee \(empToDelete.empName)")
    //
    //
    //        //get the email address of currently logged in user
    //        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
    //
    //        if (self.loggedInUserEmail.isEmpty){
    //            print(#function, "Logged in user's email address not available. Can't delete employees")
    //        }
    //        else{
    //            do{
    //                try self.db
    //                    .collection(COLLECTION_RECRUITER_EMPLOYEES)
    //                    .document(self.loggedInUserEmail)
    //                    .collection(COLLECTION_EMP)
    //                    .document(empToDelete.id!)
    //                    .delete{ error in
    //                        if let err = error {
    //                            print(#function, "Unable to delete employee from database : \(err)")
    //                        }else{
    //                            print(#function, "Employee \(empToDelete.empName) successfully deleted from database")
    //                        }
    //                    }
    //            }catch let err as NSError{
    //                print(#function, "Unable to delete employee from database : \(err)")
    //            }
    //        }
    //    }
    //
    //
    //
    //    func updateEmployee(empToUpdate : Employee){
    //        print(#function, "Updating employee \(empToUpdate.empName), ID : \(empToUpdate.id)")
    //
    //
    //        //get the email address of currently logged in user
    //        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
    //
    //        if (self.loggedInUserEmail.isEmpty){
    //            print(#function, "Logged in user's email address not available. Can't update employees")
    //        }
    //        else{
    //            do{
    //                try self.db
    //                    .collection(COLLECTION_RECRUITER_EMPLOYEES)
    //                    .document(self.loggedInUserEmail)
    //                    .collection(COLLECTION_EMP)
    //                    .document(empToUpdate.id!)
    //                    .updateData([FIELD_EMPNAME : empToUpdate.empName,
    //                                    FIELD_ROLE : empToUpdate.isManager,
    //                                FIELD_MGR_NAME : empToUpdate.managerName,
    //                           FIELD_CONTRIBUTIONS : empToUpdate.empContributions]){ error in
    //
    //                        if let err = error {
    //                            print(#function, "Unable to update employee in database : \(err)")
    //                        }else{
    //                            print(#function, "Employee \(empToUpdate.empName) successfully updated in database")
    //                        }
    //                    }
    //            }catch let err as NSError{
    //                print(#function, "Unable to update employee in database : \(err)")
    //            }
    //        }
    //    }
    
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
    //
    //    func getAllEmployees(){
    //        print(#function, "Trying to get all employees.")
    //
    //
    //        //get the email address of currently logged in user
    //        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
    //
    ////        get the instance of Auth Helper to access all the user details
    ////        self.loggedInUserEmail = self.authHelper.user.email
    //
    //        if (self.loggedInUserEmail.isEmpty){
    //            print(#function, "Logged in user's email address not available. Can't show employees")
    //        }
    //        else{
    //            do{
    //
    //                self.db
    //                    .collection(COLLECTION_RECRUITER_EMPLOYEES)
    //                    .document(self.loggedInUserEmail)
    //                    .collection(COLLECTION_EMP)
    //                    .addSnapshotListener({ (querySnapshot, error) in
    //
    //                        guard let snapshot = querySnapshot else{
    //                            print(#function, "Unable to retrieve data from database : \(error)")
    //                            return
    //                        }
    //
    //                        snapshot.documentChanges.forEach{ (docChange) in
    //
    //                            do{
    //                                //convert JSON document to swift object
    //                                var emp : Employee = try docChange.document.data(as: Employee.self)
    //
    //                                //get the document id so that it can be used for updating and deleting document
    //                                var documentID = docChange.document.documentID
    //
    //                                //set the firestore document id to the converted object
    //                                emp.id = documentID
    //
    //                                print(#function, "Document ID : \(documentID)")
    //
    //                                //if new document added, perform required operations
    //                                if docChange.type == .added{
    //                                    self.empList.append(emp)
    //                                    print(#function, "New document added : \(emp.empName)")
    //                                }
    //
    //                                //get the index of any matching object in the local list for the firestore document that has been deleted or updated
    //                                let matchedIndex = self.empList.firstIndex(where: { ($0.id?.elementsEqual(documentID))! })
    //
    //                                //if a document deleted, perform required operations
    //                                if docChange.type == .removed{
    //                                    print(#function, " document removed : \(emp.empName)")
    //
    //                                    //remove the object for deleted document from local list
    //                                    if (matchedIndex != nil){
    //                                        self.empList.remove(at: matchedIndex!)
    //                                    }
    //                                }
    //
    //                                //if a document updated, perform required operations
    //                                if docChange.type == .modified{
    //                                    print(#function, " document updated : \(emp.empName)")
    //
    //                                    //update the existing object in local list for updated document
    //                                    if (matchedIndex != nil){
    //                                        self.empList[matchedIndex!] = emp
    //                                    }
    //                                }
    //
    //                            }catch let err as NSError{
    //                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
    //                            }
    //
    //                        }//ForEach
    //
    //                    })//addSnapshotListener
    //
    //            }catch let err as NSError{
    //                print(#function, "Unable to get all employee from database : \(err)")
    //            }//do..catch
    //        }//else
    //    }
    //
    //
    //    func createUserProfile(){
    //
    //    }
    //
    //    func updateUserProfile(){
    //
    //    }
    
}
