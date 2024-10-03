//
//  ContentView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 2/10/24.
//

import SwiftUI
import UserNotifications
import OneSignalExtension

struct ContentView: View {
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            
            if idToken.isEmpty {
               Text("Si hay token!!")
            } else {
                Text("No hay token")
            }
        }
        .padding()
        
      
    }
}

#Preview {
    ContentView()
}
