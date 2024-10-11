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
    
    @State private var showToastBool: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0

    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    var body: some View {
        ZStack {
            // Fondo de la vista
            Color(temaApp == 1 ? .black : .white)
                .ignoresSafeArea() // Asegúrate de que el color de fondo cubra toda la pantalla

            ScrollView {
                VStack(spacing: 15) {
                    Image("correootp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 0)
                    
                    // Agrega más contenido aquí si es necesario
                }
                .padding()
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-recuperacion"))
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                Text(TextoIdiomaController.localizedString(forKey: "key-atras"))
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                        }
                    }
                }
                .background(CustomNavigationBarModifier(backgroundColor: temaApp == 1 ? .black : .white, titleColor: temaApp == 1 ? .white : .black))
            }
            
            // Cargando el spinner
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity) // Transición de opacidad
                    .zIndex(10)
            }

            // Toast
           /* .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
                customToast
            }*/
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    PerfilView()
}
