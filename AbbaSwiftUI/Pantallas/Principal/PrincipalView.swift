//
//  PrincipalView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 6/10/24.
//

import SwiftUI

struct PrincipalView: View {
    
    @StateObject private var idiomaSettings = IdiomaSettings()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            InicioView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(TextoIdiomaController.localizedString(forKey: "key-inicio"))
                }

            DevocionalView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text(TextoIdiomaController.localizedString(forKey: "key-devocional"))
                }

            BibliaView()
                .tabItem {
                    Image(systemName: "book.circle.fill")
                    Text(TextoIdiomaController.localizedString(forKey: "key-biblia"))
                }
            
            AjustesView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(TextoIdiomaController.localizedString(forKey: "key-ajustes"))
                }
        }.accentColor(.black)
         .environmentObject(idiomaSettings)
    }
}

#Preview {
    PrincipalView()
}
