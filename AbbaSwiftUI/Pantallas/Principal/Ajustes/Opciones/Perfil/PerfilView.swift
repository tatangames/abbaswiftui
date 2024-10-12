//
//  CodigoOTPView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 6/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation


// AQUI SE INGRESA EL CODIGO RECIBIDO POR CORREO

struct PerfilView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0
    
    @State private var showToastBool: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var password: String = ""

    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    
    init() {
          // Configuración global de la apariencia de UINavigationBar
          UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
          UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
      }
      
    
    var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                     
                        
                        
                        
                        
                        
                        
                        
                        
                        if openLoadingSpinner {
                            LoadingSpinnerView()
                                .transition(.opacity)
                                .zIndex(10)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                            Text(TextoIdiomaController.localizedString(forKey: "key-atras"))
                                .foregroundColor(.black)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-actualizacion"))
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }.background(temaApp == 1 ? Color.black : Color.white) // fondo de pantalla
            } // end-navigationView
            .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                    titleColor: .black))
        }
    
    
    
}
