//
//  listOfEventView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI

struct listOfEventView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @Binding var rootScreen: Int
    @StateObject var locationManager = LocationManager()
    let PRIVATE_KEY = "MzQ1MTI1MDB8MTY4NzY2MzQ3MC45MTU3MDcz"
    @State var eventAll: Event?
    
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double){
        
    }
    
    func loadDataFromApi(lat:String, lon: String){
        
        let webAdd = "https://api.seatgeek.com/2/events?lat=\(lat)&lon=\(lon)&client_id=\(PRIVATE_KEY)"

        guard let apiURL = URL(string: webAdd) else{
            print("Error cannot convert api address to an url object")
            return
        }
        let request = URLRequest(url: apiURL)
        let task = URLSession.shared.dataTask(with: request){
            (data:Data?, response, error) in
            if let jsonData = data{
                if let decodedResponse = try? JSONDecoder().decode(Event.self, from: jsonData){
                    eventAll = decodedResponse
                    DispatchQueue.main.async{
                        print(decodedResponse)
                    }
                }else{
                    print("cannot convert json to Event object")
                }
            }else{
                print("nil data")
            }
        }
        task.resume()
    }
    
    var body: some View {
        VStack{
            switch locationManager.locationManager.authorizationStatus{
            case .authorizedWhenInUse:
                if let lo = locationManager.loca{
                    Text("Find Events Near you").font(.title)
                    if let eve = eventAll{
                        let eventWithIndex = eve.events.enumerated().map({$0})
                        List(eventWithIndex, id: \.element.id){
                            index, activity in
                            VStack(alignment: .center){
                                
                                AsyncImage(url: URL(string: activity.performers[0].image)){
                                    
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
                                    
                                
                                Text("\(index+1). \(activity.shortTitle)")
                            }
                        }
                    }
                }else{
                    Text("Finding your location...")
                    ProgressView()
                }
            case .restricted, .denied:
                Text("Cannot access to your location")
            case .notDetermined:
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
        }.onAppear(){
            print("list userdefault: ", UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? "nil")
        }.onChange(of: locationManager.loca) { newValue in
            guard let lat = newValue?.coordinate.latitude.description else{
                print("cannot find latitude")
                return
            }
            guard let lon = newValue?.coordinate.longitude.description else{
                print("cannot find longitude")
                return
            }
            print("in on change")
            loadDataFromApi(lat: lat, lon: lon)

        }.offset(y:-5)
    }
}

//struct listOfEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        listOfEventView()
//    }
//}
