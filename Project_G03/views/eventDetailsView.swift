//
//  eventDetailsView.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import SwiftUI

struct eventDetailsView: View {
    
    @EnvironmentObject var authHelper: FireAuthController
    @Binding var rootScreen: Int
    
    var body: some View {
        Text("This is event details view")
    }
}

//struct eventDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        eventDetailsView()
//    }
//}
