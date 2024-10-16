//
//  InformacionPlanView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 15/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation

struct InformacionPlanView: View {
    
    var settings: TabsDevocionalSettings
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var boolActivarVista = false
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = true
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = InformacionPlanViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
                
        NavigationView {
            ZStack {
                VStack() {
                    
                    if(boolActivarVista){
                        
                        VStack {
                            // Imagen en la parte superior
                            Image("libroa") // Reemplaza con el nombre de la imagen o una URL si es remota
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250) // Ajusta el tamaño máximo de la imagen
                                .padding()
                                                        
                        }
                        .background(temaApp == 1 ? Color.black : Color.white) // Cambia el fondo según el tema
                        .edgesIgnoringSafeArea(.bottom)
                        
                        
                    }
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModel.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-informacion"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
            }
            .background(temaApp == 1 ? Color.black : Color.white) // fondo de pantalla
            .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                toastViewModel.customToast
            })
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    
    private func loadData(){
        
        openLoadingSpinner = true
        viewModel.informacionPlanRX(idToken: idToken, idPlan: settings.selectedBuscarPlanID, idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                          
                    boolActivarVista = true
                                        
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    private func mensajeError(){
        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
    }
    
    
}

