//
//  ContrasenaAjustesView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 11/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation

struct ContrasenaAjustesView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    
    @StateObject private var toastViewModel = ToastViewModel()
    @State private var showToastBool: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var password: String = ""
    
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    let viewModel = ResetPasswordViewModel()
        
    var body: some View {
            NavigationView {
                ZStack {
                    ScrollView{
                        VStack() {
                            
                            Image("newkey")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.top, 15)
                            
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-nueva-contrasena"), isDarkMode: temaApp, aplicarTema: true)
                            
                            CustomPasswordField(
                                labelKey: "key-contrasena",  // Placeholder personalizado
                                isDarkMode: temaApp == 1 ? true : false,                   // Modo claro u oscuro
                                password: $password,                 // Variable que contiene la contraseña
                                maxLength: 20                        // Longitud máxima de la contraseña
                            )
                            
                            //****************  BOTON ENVIAR NUEVA CONTRASEÑA   *********************************
                            
                            Button(action: {
                                verificarCampos()
                            }) {
                                Text(TextoIdiomaController.localizedString(forKey: "key-actualizar"))
                                    .font(.headline)
                                    .foregroundColor(temaApp == 1 ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(temaApp == 1 ? .white : Color("cazulv1"))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 50)
                            .opacity(1.0)
                            .buttonStyle(NoOpacityChangeButtonStyle())
                            
                            Spacer()
                            
                            if openLoadingSpinner {
                                LoadingSpinnerView()
                                    .transition(.opacity)
                                    .zIndex(10)
                            }
                        }
                        .frame(maxWidth: .infinity) // para expansion
                        .padding()
                    }// end-scrollview
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // para expansion
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
                 .onReceive(viewModel.$loadingSpinner) { loading in
                        openLoadingSpinner = loading
                 }
                 .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                        toastViewModel.customToast ?? AlertToast(type: .regular, title: "")
                 })
            } // end-navigationView
            .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                    titleColor: .black))
        }
    
    private func verificarCampos(){
        if(password.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-password-requerido"), tipoColor: .gris)
            return
        }
        if(password.count < 5){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-contrasena-minimo-cinco"), tipoColor: .gris)
            return
        }
        apiEnviar()
    }
    
    private func apiEnviar(){
        if !viewModel.isRequestInProgress {
            viewModel.resetPasswordRX(password: password, token: idToken)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let json):
                        let success = json["success"].int ?? 0
                        
                        switch success {
                        case 1:
                            // contrasena cambiada
                            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-actualizado"), tipoColor: .verde)
                        default:
                            // error
                            mensajeError()
                        }
                    case .failure(_):
                        mensajeError()
                    }
                }, onError: { error in
                    mensajeError()
                })
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    private func mensajeError(){
        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
    }
 
}
