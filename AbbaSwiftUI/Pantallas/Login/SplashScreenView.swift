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
        
    @State private var boolActivarCambio: Bool = false
    @State private var activeView: EnumTipoVistaSplash?
    
    var body: some View {
        ZStack {
            
            Color.white.edgesIgnoringSafeArea(.all)
                
            GeometryReader { geometry in
                Image("fondov2")
                    .resizable()
                    .scaledToFill() // Escala la imagen para llenar el contenedor
                    .frame(width: geometry.size.width, height: geometry.size.height) // Ajusta el tamaño según la pantalla
                    .clipped() // Recorta lo que sobrepase el contenedor
                    .ignoresSafeArea(edges: .vertical) // Ignora áreas seguras en la parte superior e inferior
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    // si hay token
                    if (idToken.isEmpty){
                        activeView = .login
                    }else{
                        activeView = .principal
                    }
                    boolActivarCambio = true
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
        
        .fullScreenCover(item: $activeView) { view in
            switch view {
            case .login:
                LoginPresentacionView()
            case .principal:
                PrincipalView()
            }
        }
    } // end-body
    
    
}



#Preview {
    SplashScreenView()
}
