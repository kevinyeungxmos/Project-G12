//
//  eventDetailsView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI
import FirebaseAuth
import MapKit

struct eventDetailsView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @Binding var rootScreen: Int
    var event: EventInfo?
    @State var markerLocation: [MMarker] = []
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        VStack{
            if let e = event{
                Text("\(e.title)")
                AsyncImage(url: URL(string: e.img)){
                    phase in
                    switch phase{
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        HStack{
                            Spacer()
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 100)
                                .padding()
                            Spacer()
                        }
                    case .failure:
                        Image(systemName: "photo")
                    default:
                        EmptyView()
                    }
                }
                Text("Venue: \(e.venue)")
                Text("Address: \(e.address)")
                Text("City: \(e.city)")
                Text("Performer: \(e.performer)")
                Text("Date: \(e.date)")
                Text("Venue: \(e.venue)")
                Text("Price: \(e.price)")
                HStack{
                    Text("Website:")
                    Link("\(e.url)", destination: URL(string: e.url)!)
                }
                
            }else{
                Text("Error: Cannot find event")
            }
            
            Map(coordinateRegion: self.$region, showsUserLocation: true, annotationItems: self.markerLocation){
                lo in
                MapMarker(coordinate: lo.coordinate)
            }
        }.onAppear{
            markerLocation = [MMarker(coordinate: CLLocationCoordinate2D(latitude: Double(event!.lat)! , longitude: Double(event!.lon)!), show: false)]
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(event!.lat)!, longitude: Double(event!.lon)!), span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
            dbHelper.getMyEvent(email: Auth.auth().currentUser?.email ?? "")
        }.overlay(alignment: .bottom, content: {
    
            if dbHelper.myEventList.contains(where: {
                evn in
                if evn.id == event?.id{
                    return true
                }
                return false
            }){
                removeEventButton
            }else{
                addEventButton
            }
        })
        
        
    }
    
    private var addEventButton : some View{
        Button{
            if let userEmail = Auth.auth().currentUser{
                print("Already signed in")
                print("\(Auth.auth().currentUser?.email)")
                if userEmail.email == UserDefaults.standard.string(forKey: "KEY_EMAIL"){
                    print("match with the userdefault")
                    dbHelper.insertEventtoUserEventList(email: userEmail.email!, event: event!)
                    
                }else{
                    print("userdefault: \(UserDefaults.standard.string(forKey: "KEY_EMAIL"))")
                    print("No Authentication. Cannot add Event Please Sign In!")
                }
            }else{
                print("Please Login")
            }

        }label: {
            HStack{
                Spacer()
                Text("+ Add Event").font(.system(size: 16, weight: .bold))
                Spacer()
            }.foregroundColor(.white)
                .padding(.vertical)
                .background(.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 5)
        }
    }
    
    private var removeEventButton : some View{
        Button{
            if let userEmail = Auth.auth().currentUser{
                print("Already signed in")
                print("\(Auth.auth().currentUser?.email)")
                if userEmail.email == UserDefaults.standard.string(forKey: "KEY_EMAIL"){
                    print("match with the userdefault")
                    dbHelper.removeEvent(eventToRemove: event!)
                    
                }else{
                    print("userdefault: \(UserDefaults.standard.string(forKey: "KEY_EMAIL"))")
                    print("No Authentication. Cannot add Event Please Sign In!")
                }
            }else{
                print("Please Login")
            }

        }label: {
            HStack{
                Spacer()
                Text("- Remove Event").font(.system(size: 16, weight: .bold))
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

//struct eventDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        eventDetailsView()
//    }
//}
