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

struct NotificacionesAjustesView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = ListaNotificacionesViewModel()
    @StateObject var viewModelBorrarNoti = BorrarNotificacionesViewModel()
    @State private var openLoadingSpinner: Bool = false
    @State private var openLoadingSpinnerBorrarNoti: Bool = false
    @State private var password: String = ""
    @State private var boolVistaHabilitar: Bool = false
    @State private var boolVistaHayDatos: Bool = false
    @State private var popBorrarNotificaciones: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack() {
                    // Solo se habilita si hay informacion, se ocultara al eliminar notificaciones
                    if(boolVistaHabilitar){
                        if(boolVistaHayDatos){
                            List {
                                ForEach(viewModel.notifications) { notification in
                                    
                                    HStack(alignment: .top, spacing: 5) {
                                        Image(systemName: "bell.fill") // Reemplaza con el nombre de tu imagen de icono
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(temaApp == 1 ? Color(UIColor.systemGray3) : .black)
                                            .padding(.top, 5) // Opcional, ajusta para alinear mejor con el texto
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(notification.titulo)
                                                .font(.headline)
                                                .foregroundColor(temaApp == 1 ? Color.white : Color.black)
                                            
                                            Text(notification.fecha)
                                                .font(.headline)
                                                .foregroundColor(Color(UIColor.systemGray3))
                                                .font(.system(size: 10, design: .rounded))
                                                .padding(.top,4)
                                            
                                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                                                .padding(.top, 4)
                                        }
                                    }
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                                    .onAppear {
                                        // Cargar más datos si el usuario llega al final de la lista
                                        if notification == viewModel.notifications.last && viewModel.hasMorePages && !viewModel.isRequestInProgress {
                                            viewModel.fetchNotifications(idCliente: idCliente, idToken: idToken, idioma: idiomaApp)
                                                .subscribe(onNext: { result in
                                                    switch result {
                                                    case .success:
                                                        print("Page \(viewModel.currentPage - 1) fetched successfully")
                                                    case .failure(let error):
                                                        print("Failed to fetch notifications: \(error.localizedDescription)")
                                                    }
                                                })
                                                .disposed(by: viewModel.disposeBag)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            .scrollContentBackground(.hidden)
                            .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6))
                            
                        }else{
                            VStack {
                                Image("notificaciones")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 15)
                                
                                HStack {
                                    Spacer() // Empuja el contenido a la derecha
                                    Text(TextoIdiomaController.localizedString(forKey: "key-no-hay-notificaciones"))
                                        .foregroundColor(temaApp == 1 ? .white : .black)
                                        .bold()
                                    Spacer() // Empuja el contenido a la izquierda, centrando el texto
                                }
                                .padding(.top, 25)
                                
                                Spacer() // Esto empuja todo hacia la parte superior
                            }
                            .padding()
                        }
                    }
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModelBorrarNoti.$loadingSpinner) { loading in
                    openLoadingSpinnerBorrarNoti = loading
                }
                
                if popBorrarNotificaciones {
                    PopImg2BtnView(isActive: $popBorrarNotificaciones, imagen: .constant("infocolor"), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-borrar-notificaciones")), txtCancelar: .constant(TextoIdiomaController.localizedString(forKey: "key-no")),
                                   txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-si")),
                                   cancelAction: {popBorrarNotificaciones = false},
                                   acceptAction: {
                        requestBorrarNotificaciones()
                        
                    }).zIndex(1)
                }
                
                if openLoadingSpinner && viewModel.hasMorePages {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
                
                if openLoadingSpinnerBorrarNoti {
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-actualizacion"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Acción para el botón de basurero
                        
                        
                        if(boolVistaHayDatos){
                            popBorrarNotificaciones = true
                        }else{
                            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-no-hay-notificaciones"), tipoColor: .gris)
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.black) // Cambia el color según tu preferencia
                    }
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
    
    
    private func requestBorrarNotificaciones(){
        viewModelBorrarNoti.borrarNotificacionesRX(idToken: idToken, idiomaPlan: idiomaApp) { result in
            switch result {
            case .success(let json):
                
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    boolVistaHayDatos = false
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-notificaciones-borradas"), tipoColor: .verde)
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    private func loadData() {
        openLoadingSpinner = true
        viewModel.fetchNotifications(idCliente: idCliente, idToken: idToken, idioma: idiomaApp)
            .subscribe(onNext: { result in
                switch result {
                case .success(let notificationResponse):
                    
                    if(notificationResponse.hayinfo == 1){
                        boolVistaHayDatos = true
                    }
                    
                    boolVistaHabilitar = true
                    
                    // Acceder a otros datos de la respuesta si es necesario
                    if let nextPageURL = notificationResponse.listado.nextPageURL {
                        print("Next page URL: \(nextPageURL)")
                    } else {
                        print("No more pages to load.")
                    }
                    
                case .failure(let error):
                    print("Failed to fetch initial notifications: \(error)")
                }
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func mensajeError(){
        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
    }
    
}
