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
    
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @State private var boolPantallaPrincipal: Bool = false
    @State private var boolPantallaPassOlvidada: Bool = false
    @State private var correo:String = ""
    @State private var password:String = ""
    
    let viewModel = LoginViewModel()
    
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    Image("abba_logo")
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
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                
                                Text(TextoIdiomaController.localizedString(forKey: "key-atras"))
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                        }
                    }
                }
            }
            .background(CustomNavigationBarModifier(backgroundColor: temaApp == 1 ? .black : .white,
                                                    titleColor: temaApp == 1 ? .white : .black))
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
        .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
            customToast
        }
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
        
        if(correo.isEmpty){
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-requerido"), tipoColor: .gris)
            return
        }
        
        if !isValidEmail(correo) {
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-no-valido"), tipoColor: .gris)
            return
        }
        
        if(password.isEmpty){
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-password-requerido"), tipoColor: .gris)
            return
        }
        
        apiServerLogin()
    }
    
    private func apiServerLogin(){
        if !viewModel.isRequestInProgress {
            
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
                            self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-o-contrasena-incorrecto"), tipoColor: .gris)
                        default:
                            // error
                            self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                        }
                        
                    case .failure(_):
                        self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                    }
                }, onError: { error in
                    self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                })
                .disposed(by: viewModel.disposeBag)
        }
    }
    
    // Función para configurar y mostrar el toast
    func showCustomToast(with mensaje: String, tipoColor: ToastColor) {
        let titleColor = tipoColor.color
        customToast = AlertToast(
            displayMode: .banner(.pop),
            type: .regular,
            title: mensaje,
            subTitle: nil,
            style: .style(
                backgroundColor: titleColor,
                titleColor: Color.white,
                subTitleColor: Color.blue,
                titleFont: .headline,
                subTitleFont: nil
            )
        )
        showToastBool = true
    }
    
    
}

#Preview {
    RegistroView()
}
