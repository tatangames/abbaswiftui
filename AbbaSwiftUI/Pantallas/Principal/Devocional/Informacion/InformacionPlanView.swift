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
import SDWebImageSwiftUI

struct InformacionPlanView: View {
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var boolActivarVista = false
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = true
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = InformacionPlanViewModel()
    @StateObject var viewModelIniciarSolo = InformacionPlanIniciarPlanViewModel()
    
    @State private var urlImagen:String = ""
    @State private var titulo:String = ""
    @State private var popIniciarPlanSolo: Bool = false
    @State private var boolCambiarVista: Bool = false
    
    @ObservedObject var settingsVista: GlobalVariablesSettings
    @Environment(\.dismiss) var dismiss
    
    @State private var boolInicioPlanConAmigos:Bool = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack() {
                    
                    if(boolActivarVista){
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                WebImage(url: URL(string: baseUrlImagen + urlImagen))
                                    .resizable()
                                    .indicator(.activity)
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 20)
                                
                                
                                HStack {
                                    Text(titulo)
                                        .foregroundColor(temaApp == 1 ? .white : .black)
                                        .font(.system(size: 22, weight: .bold))
                                        .background(.clear)
                                    Spacer() // Este Spacer empuja el texto hacia la izquierda
                                }
                                .padding()
                                
                                // *** BOTONES
                                
                                Button(action: {
                                    popIniciarPlanSolo = true
                                }) {
                                    Text(TextoIdiomaController.localizedString(forKey: "key-iniciar-plan"))
                                        .font(.headline)
                                        .foregroundColor(temaApp == 1 ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(temaApp == 1 ? .white : Color("cazulv1"))
                                        .cornerRadius(8)
                                }
                                .padding(.top, 40)
                                .opacity(1.0)
                                .buttonStyle(NoOpacityChangeButtonStyle())
                                
                                
                                HStack {
                                    // Imagen a la izquierda
                                    Image("amigos") // Reemplaza "amigos" con el nombre de tu imagen en los assets
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50) // Ajusta el tamaño de la imagen según tus necesidades
                                        .padding(.trailing, 5) // Espacio entre la imagen y el botón
                                    
                                    // VStack para centrar el botón
                                    VStack {
                                        Spacer() // Este Spacer empuja el botón hacia abajo
                                        Button(action: {
                                            // Acción del botón
                                            boolCambiarVista = true
                                        }) {
                                            Text(TextoIdiomaController.localizedString(forKey: "key-iniciar-plan-conamigos"))
                                                .font(.headline)
                                                .foregroundColor(temaApp == 1 ? .black : .white)
                                                .frame(maxWidth: .infinity) // Expande el botón para ocupar el espacio disponible
                                                .padding()
                                                .background(temaApp == 1 ? .white : Color("cazulv1"))
                                                .cornerRadius(8)
                                        }
                                        .padding(.top, 10) // Añade un padding para espaciar el botón
                                        .opacity(1.0)
                                        .buttonStyle(NoOpacityChangeButtonStyle())
                                        Spacer() // Este Spacer ayuda a centrar el botón verticalmente
                                    }
                                }
                                .padding(.horizontal, 0)
                                
                                
                                
                            }
                            .padding()
                        }
                        
                        
                    }
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModel.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                .onReceive(viewModelIniciarSolo.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                .fullScreenCover(isPresented: $boolCambiarVista) {
                    ListaAmigosIniciarPlanView(settingsVista: settingsVista, boolInicioPlanConAmigos: $boolInicioPlanConAmigos)
                }
                .onChange(of: boolInicioPlanConAmigos) { newValue in
                    if newValue {
                        
                        settingsVista.updateTabsBuscarPlan = true
                        settingsVista.updateTabsMiPlan = true
                        dismiss()
                    }
                }
                
                if popIniciarPlanSolo {
                    PopImg2BtnView(isActive: $popIniciarPlanSolo, imagen: .constant("infocolor"), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-iniciar-plan")), txtCancelar: .constant(TextoIdiomaController.localizedString(forKey: "key-no")),
                                   txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-si")),
                                   cancelAction: {popIniciarPlanSolo = false},
                                   acceptAction: {
                        serverIniciarPlan()
                    }).zIndex(1)
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
        viewModel.informacionPlanRX(idToken: idToken, idPlan: settingsVista.selectedPlanIDGlobal, idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    let _imagen = json["imagen"].string ?? ""
                    let _titulo = json["titulo"].string ?? ""
                    
                    urlImagen = _imagen
                    titulo = _titulo
                    
                    boolActivarVista = true
                    
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    
    private func serverIniciarPlan(){
        
        viewModelIniciarSolo.iniciarPlanSoloRX(idToken: idToken, idPlan: settingsVista.selectedPlanIDGlobal, idCliente: idCliente) { result in
            switch result {
            case .success(let json):
                
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    // plan ya estaba seleccionado
                    salir()
                case 2:
                    // plan seleccionado correcto
                    salir()
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    private func salir(){
        settingsVista.updateTabsMiPlan = true
        settingsVista.updateTabsBuscarPlan = true
        dismiss()
    }
    
    private func mensajeError(){
        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
    }
}

