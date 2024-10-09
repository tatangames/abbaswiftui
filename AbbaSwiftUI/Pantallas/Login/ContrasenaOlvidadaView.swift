//
//  ContrasenaOlvidadaView.swift
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

// AQUI SE INGRESA EL CORREO PARA SOLICITAR RECUPERACION DE CONTRASEÑA

struct ContrasenaOlvidadaView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var boolPantallaCodigoOTP: Bool = false
    @State private var correo:String = ""
    
    let viewModel = CorreoOTPViewModel()
    
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    Image("correootp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 0)
                    
                    HStack {
                        Spacer() // Empuja el contenido a la derecha
                        Text(TextoIdiomaController.localizedString(forKey: "key-escribe-tu-correo-electronico"))
                            .foregroundColor(temaApp == 1 ? .white : .black)
                            .bold()
                        Spacer() // Empuja el contenido a la izquierda, centrando el texto
                    }
                    .padding(.top, 25)
                    
                    CustomTextField(labelKey: "key-correo-electronico", isDarkMode: temaApp != 0, text: $correo, maxLength: 100, keyboardType: .emailAddress)
                        .padding(.top, 25)
                    
                    
                    //****************  BOTON SOLICITAR CODIGO   *********************************
                    
                    Button(action: {
                        verificarCampos()
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-solicitar-codigo"))
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
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-recuperacion"))
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
        .navigationDestination(isPresented: $boolPantallaCodigoOTP) {
            CodigoOTPView(correo: correo)
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
        
        apiEnviarCodigo()
    }
    
    private func apiEnviarCodigo(){
        if !viewModel.isRequestInProgress {
            
            viewModel.solicitarCodigoCorreoRX(correo: correo, idioma: idiomaApp)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let json):
                        let success = json["success"].int ?? 0
                        
                        switch success {
                        case 1:
                            // correo no encontrado
                            self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-no-encontrado"), tipoColor: .gris)
                            
                        case 2:
                            // codigo enviado
                            boolPantallaCodigoOTP = true
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
