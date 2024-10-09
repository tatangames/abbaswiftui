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
    
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @State private var boolPantallaLogin: Bool = false
    @State private var password:String = ""
    @State private var popDatosActualizados:Bool = false
    
    let viewModel = ResetPasswordViewModel()
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            boolPantallaLogin = true
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
            
            if popDatosActualizados {
                PopImg1BtnView(isActive: $popDatosActualizados, imagen: .constant("infocolor"), bLlevaTitulo: .constant(false), titulo: .constant(""), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-password-actualizada")), txtAceptar: .constant("Aceptar"), acceptAction: {
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
        .toast(isPresenting: $showToastBool, duration: 3, tapToDismiss: false) {
            customToast
        }
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
        if(password.isEmpty){
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-password-requerido"), tipoColor: .gris)
            return
        }
        if(password.count < 5){
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-contrasena-minimo-cinco"), tipoColor: .gris)
            return
        }
        apiEnviar()
    }
    
    private func apiEnviar(){
        if !viewModel.isRequestInProgress {
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
    CodigoOTPView()
}
