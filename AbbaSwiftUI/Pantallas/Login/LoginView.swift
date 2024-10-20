//
//  LoginView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation

struct LoginView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var boolPantallaPrincipal: Bool = false
    @State private var boolPantallaPassOlvidada: Bool = false
    @State private var correo:String = ""
    @State private var password:String = ""
    @StateObject private var toastViewModel = ToastViewModel()
    let viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    Image("abbaround")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 0)
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-correo-electronico"), isDarkMode: temaApp, aplicarTema: true)
                    
                    CustomTextField(labelKey: "key-correo-electronico", isDarkMode: temaApp != 0, text: $correo, maxLength: 100, keyboardType: .emailAddress)
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-contrasena"), isDarkMode: temaApp, aplicarTema: true)
                    
                    CustomPasswordField(
                        labelKey: "key-contrasena",  // Placeholder personalizado
                        isDarkMode: temaApp == 1 ? true : false,                   // Modo claro u oscuro
                        password: $password,                 // Variable que contiene la contraseña
                        maxLength: 20                        // Longitud máxima de la contraseña
                    )
                    
                    Button(action: {
                        verificarCampos()
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-ingresar"))
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
                    
                    Button(action: {
                        correo = ""
                        password = ""
                        boolPantallaPassOlvidada = true
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-olvido-su-contrasena"))
                            .foregroundColor(temaApp == 1 ? .white : .black)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-iniciar-sesion"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
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
        .navigationDestination(isPresented: $boolPantallaPrincipal) {
            PrincipalView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden) // Puedes ocultar la toolbar aquí si lo deseas
        }
        .navigationDestination(isPresented: $boolPantallaPassOlvidada) {
            ContrasenaOlvidadaView()
        }
    }
    
    private func verificarCampos(){
        
        hideKeyboard()
        
        if(correo.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-requerido"), tipoColor: .gris)
            return
        }
        
        if !isValidEmail(correo) {
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-no-valido"), tipoColor: .gris)
            return
        }
        
        if(password.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-password-requerido"), tipoColor: .gris)
            return
        }
        
        apiServerLogin()
    }
    
    private func apiServerLogin(){
        viewModel.loginRX(correo: correo, contrasena: password)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    
                    switch success {
                    case 1:
                        // inicio sesion
                        let _id = json["id"].int ?? 0
                        let _token = json["token"].string ?? ""
                        
                        idCliente = String(_id)
                        idToken = _token
                        
                        boolPantallaPrincipal = true
                    case 2:
                        // datos incorrectos
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-o-contrasena-incorrecto"), tipoColor: .gris)
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
    RegistroView()
}
