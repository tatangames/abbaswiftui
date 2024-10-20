//
//  NuevaPasswordLoginView.swift
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

struct NuevaPasswordLoginView: View {
    
    // parametro recibido
    var tokenTemporal:String = ""
    
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var boolPantallaLogin: Bool = false
    @State private var password:String = ""
    @State private var popDatosActualizados:Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = ResetPasswordViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    Image("newkey")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 0)
                    
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
                        Text(TextoIdiomaController.localizedString(forKey: "key-enviar"))
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
                }
                .padding()
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-nueva-contrasena"))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            boolPantallaLogin = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.black)
                                
                                Text(TextoIdiomaController.localizedString(forKey: "key-atras"))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            }
            .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                    titleColor: .black))
            .onTapGesture {
                hideKeyboard()
            }
            if popDatosActualizados {
                PopImg1BtnView(isActive: $popDatosActualizados, imagen: .constant("infocolor"), bLlevaTitulo: .constant(false), titulo: .constant(""), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-password-actualizada")), txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-aceptar")), acceptAction: {
                    popDatosActualizados = false
                    boolPantallaLogin = true
                })
                .zIndex(1)
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity) // Transición de opacidad
                    .zIndex(10)
            }
        }
        .background(temaApp == 1 ? Color.black : Color.white)
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .navigationDestination(isPresented: $boolPantallaLogin) {
            LoginPresentacionView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
        }
    }
    
    private func verificarCampos(){
        
        hideKeyboard()
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
        viewModel.resetPasswordRX(password: password, token: tokenTemporal)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    
                    switch success {
                    case 1:
                        // contrasena cambiada
                        popDatosActualizados = true
                    default:
                        // error
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                    }
                    
                case .failure(_):
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                }
            }, onError: { error in
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
}

#Preview {
    CodigoOTPView()
}
