//
//  MeditacionView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 23/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation
import WebKit

struct MeditacionView: View {
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    
    @State private var showToastBool:Bool = false
    @State private var boolActivarVista:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = MeditacionViewModel()
    @ObservedObject var settingsVista: GlobalVariablesSettings
    
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationView {
            ZStack {
               VStack {
                    if boolActivarVista {
                        Text("Holaaa")
                            .foregroundColor(temaApp == 1 ? .white : .black) // Ajustar el color del texto según el fondo
                    }
                }
                .onAppear {
                    loadData()
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-meditacion"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
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
        viewModel.listadoPreguntasRX(idToken: idToken, idCliente: idCliente, idBlockDeta: settingsVista.selectedIdBlockDeta ,idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                
                let success = json["success"].int ?? 0
                
                switch success {
                case 1:
                                       
                   // datos
                    print("si hay preguntas")
                    boolActivarVista = true
                    
                case 2:
                    // no hay preguntas
                    print("no hay meditacion")
                    
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
    
   



