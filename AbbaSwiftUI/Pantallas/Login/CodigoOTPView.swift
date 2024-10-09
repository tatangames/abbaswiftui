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

struct CodigoOTPView: View {
    
    // parametro recibido
    var correo:String = ""
    
    @Environment(\.dismiss) var dismiss
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @State private var boolPantallaResetPassword: Bool = false
    @State private var codigo:String = ""
    @State private var tokenTemporal:String = ""
    
    let viewModel = CodigoOTPViewModel()
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    Image("keyotp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 0)
                    
                    let localizedString = TextoIdiomaController.localizedString(forKey: "key-ingresar-el-codigo-otp")
                    let formattedString = String(format: localizedString, correo)
                    
                    CustomTituloHstack(labelKey: formattedString, isDarkMode: temaApp, aplicarTema: true)
                    
                    OTPInput(numberOfFields: 6, otpCode: $codigo, temaApp: temaApp)
                        .padding(.top, 25)
                    
                    //****************  BOTON ENVIAR CODIGO   *********************************
                    
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
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-codigo"))
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss() // Regresa a la pantalla anterior
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
        .navigationDestination(isPresented: $boolPantallaResetPassword) {
            NuevaPasswordLoginView(tokenTemporal: tokenTemporal)                   
        }
    }
    
    private func verificarCampos(){
        
        if(codigo.isEmpty){
            showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-codigo-requerido"), tipoColor: .gris)
            return
        }
        
        apiEnviarCodigo()
    }
    
    private func apiEnviarCodigo(){
        if !viewModel.isRequestInProgress {
            
            viewModel.enviarCodigoOtpRX(correo: correo, codigo: codigo)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let json):
                        let success = json["success"].int ?? 0
                        
                        switch success {
                        case 1:
                            // viene token para cambiar
                            let _token = json["token"].string ?? ""
                            tokenTemporal = _token
                            boolPantallaResetPassword = true
                            
                        case 2:
                            // codigo incorrecto
                            self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-codigo-incorrecto"), tipoColor: .gris)
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
