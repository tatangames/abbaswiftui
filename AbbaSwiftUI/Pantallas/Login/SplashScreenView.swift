//
//  SplashScreenView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken: String = ""
    @AppStorage(DatosGuardadosKeys.setearLenguaje) private var setearLenguaje: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var boolPantallaPrincipal: Bool = false
    @State private var boolPantallaInicial: Bool = false
    
    
    var body: some View {
        // NavigationStack {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            Image("fondov2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    if (idToken.isEmpty){
                        boolPantallaInicial = true
                    }else{
                        boolPantallaPrincipal = true
                    }
                }
            }
        }.onAppear{
            if(setearLenguaje == 0){
                let deviceLanguage = Locale.preferredLanguages.first
                if let deviceLanguage = deviceLanguage{
                    
                    if deviceLanguage.hasPrefix("es")  {
                        // espanol
                        idiomaApp = 1
                    }
                    else{
                        // ingles
                        idiomaApp = 2
                    }
                }else{
                    // espanol defecto
                    idiomaApp = 1
                }
                setearLenguaje = 1
                
                // Modificar Tema
                
                if(colorScheme == .dark){
                    temaApp = 1
                }else{
                    temaApp = 0
                }
            }
        }
        .navigationDestination(isPresented: $boolPantallaInicial) {
            LoginPresentacionView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
        }
        .navigationDestination(isPresented: $boolPantallaPrincipal) {
            PrincipalView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
        }
        //}
    } // end-body
}

#Preview {
    SplashScreenView()
}
