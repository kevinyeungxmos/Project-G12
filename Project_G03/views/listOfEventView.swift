//
//  listOfEventView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct listOfEventView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @Binding var rootScreen: Int
//    @Binding var eventToDetail: EventInfo?
    @StateObject var locationManager = LocationManager()
    let PRIVATE_KEY = "MzQ1MTI1MDB8MTY4NzY2MzQ3MC45MTU3MDcz"
    @State var eventAll: Event?
    @State var eventList = [EventInfo]()
    @State var isFilter = false
    @State var city = ""
    
//    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double){
//
//    }
    
    func removeEvent(at offsets: IndexSet){
        eventList.remove(atOffsets: offsets)
        print(eventList.count)
    }
    
    func searchCity(cityToSearch: String){
        
        eventList.removeAll()
        
        let webAdd = "https://api.seatgeek.com/2/events?venue.city=\(cityToSearch)&client_id=\(PRIVATE_KEY)"
        

        guard let apiURL = URL(string: webAdd) else{
            print("Error cannot convert api address to an url object")
            return
        }
        let request = URLRequest(url: apiURL)
        let task = URLSession.shared.dataTask(with: request){
            (data:Data?, response, error) in
            if let jsonData = data{
                if let decodedResponse = try? JSONDecoder().decode(Event.self, from: jsonData){
    
                    for ev in decodedResponse.events{
                        var priceRange: String = "Unknown"
                        if let lowPrice = ev.stats.lowestPrice{
                            if let highPrice = ev.stats.highestPrice{
                                priceRange = "\(lowPrice) - \(highPrice)"
                            }
                        }
                        let e = EventInfo(id: ev.id, title: "\(ev.type) - \(ev.shortTitle)", performer: ev.performers[0].name, date: ev.datetimeUTC, img: ev.performers[0].image, venue: ev.venue.name ?? "Unknown", address: ev.venue.address ?? "Unknown", city: ev.venue.city ?? "Unknown", lat: String(ev.venue.location?.lat ?? 0.00), lon: String(ev.venue.location?.lon ?? 0.0), price: priceRange, url: ev.url)
                        eventList.append(e)
                        print("appended newList")
                    }
                }else{
                    print("cannot convert json to Event object")
                }
//                do{
//                    let d = try JSONDecoder().decode(Event.self, from: jsonData)
//                }catch{
//                    print(String(describing: error))
//                }
            }else{
                print("nil data")
            }
        }
        task.resume()
    }
    
    func loadDataFromApi(lat:String, lon: String){
        
        self.eventList.removeAll()
        
        let webAdd = "https://api.seatgeek.com/2/events?lat=\(lat)&lon=\(lon)&client_id=\(PRIVATE_KEY)"

        guard let apiURL = URL(string: webAdd) else{
            print("Error cannot convert api address to an url object")
            return
        }
        let request = URLRequest(url: apiURL)
        let task = URLSession.shared.dataTask(with: request){
            (data:Data?, response, error) in
            if let jsonData = data{
//                do {
//                    let doo = try JSONDecoder().decode(Event.self, from: jsonData)
//                }catch{
//                    print(String(describing: error))
//                }
                if let decodedResponse = try? JSONDecoder().decode(Event.self, from: jsonData){
                    eventAll = decodedResponse
                    DispatchQueue.main.async {
                        for ev in decodedResponse.events{
                            var priceRange: String = "Unknown"
                            if let lowPrice = ev.stats.lowestPrice{
                                if let highPrice = ev.stats.highestPrice{
                                    priceRange = "$\(lowPrice) - $\(highPrice)"
                                }
                            }
                            let e = EventInfo(id: ev.id, title: "\(ev.type) - \(ev.shortTitle)", performer: ev.performers[0].name, date: ev.datetimeUTC, img: ev.performers[0].image, venue: ev.venue.name ?? "Unknown", address: ev.venue.address ?? "Unknown", city: ev.venue.city ?? "Unknown", lat: String(ev.venue.location?.lat ?? 0.00), lon: String(ev.venue.location?.lon ?? 0.0), price: priceRange, url: ev.url)
                            self.eventList.append(e)
                            print("append eventlist")
                        }
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
            HStack{
                TextField("Search by city", text: self.$city).padding().textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    isFilter.toggle()
                    searchCity(cityToSearch: self.city)
                }){
                    Text("Search")
                }
                
                Button(action: {
                    isFilter.toggle()
                    guard let lat = locationManager.loca?.coordinate.latitude.description else{
                        print("cannot find latitude")
                        return
                    }
                    guard let lon = locationManager.loca?.coordinate.longitude.description else{
                        print("cannot find longitude")
                        return
                    }
                    loadDataFromApi(lat: lat, lon: lon)
                    
                }){
                    Text("Nearby")
                }
            }
            switch locationManager.locationManager.authorizationStatus{
            case .authorizedWhenInUse:
                if !isFilter{
                    if let lo = locationManager.loca{
                        Text("Find Events Near you").font(.title)

                        List{
                            ForEach(eventList, id: \.self){ event in
                                NavigationLink{
                                    eventDetailsView(rootScreen: $rootScreen, event: event).environmentObject(authHelper).environmentObject(dbHelper)
                                }label: {
                                    VStack(alignment: .center){
                                        AsyncImage(url: URL(string: event.img)){
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
                                        Text("\(event.title) City: \(event.city)")
                                    }
                                }
                            }
                        }
                        
                    }
                }else{
                    if let lo = locationManager.loca{
                        Text("Find Events Near you").font(.title)

                        List{
                            ForEach(eventList, id: \.self){ event in
                                
                                NavigationLink{
                                    eventDetailsView(rootScreen: $rootScreen, event: event).environmentObject(authHelper).environmentObject(dbHelper)
                                }label: {
                                    VStack(alignment: .center){
                                        AsyncImage(url: URL(string: event.img)){
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
                                        Text("\(event.title) City: \(event.city)")
                                    }
                                }
                                
                            }
                        }
                        
                    }
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
