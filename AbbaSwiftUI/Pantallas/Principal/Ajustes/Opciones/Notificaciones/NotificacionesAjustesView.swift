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
    @State private var showToastBool: Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var password: String = ""
    
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    @StateObject var viewModel = ListaNotificacionesViewModel()
    
    @State private var boolVistaHabilitar: Bool = false
    @State private var boolHabiaDatos: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack() {
                    
                    if(boolVistaHabilitar){
                        if(boolHabiaDatos){
                            List {
                                ForEach(viewModel.notifications) { notification in
                                   
                                    
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Text(notification.titulo)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        Text("Fecha: \(notification.fecha)")
                                            .foregroundColor(temaApp == 1 ? .white : .black)
                                            .font(.headline)
                                        
                                        LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
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
                                    
                                    
                                    
                                    
                                   /* VStack(alignment: .leading) {
                                        Text(notification.titulo)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        Text("Fecha: \(notification.fecha)")
                                            .foregroundColor(temaApp == 1 ? .white : .black)
                                            .font(.headline)
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
                                    }*/
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
               
                
                
                if openLoadingSpinner && viewModel.hasMorePages {
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
            }
            .background(temaApp == 1 ? Color.black : Color.white) // fondo de pantalla
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                toastViewModel.customToast ?? AlertToast(type: .regular, title: "")
            })
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    
    private func loadData() {
        openLoadingSpinner = true
        
        viewModel.fetchNotifications(idCliente: idCliente, idToken: idToken, idioma: idiomaApp)
            .subscribe(onNext: { result in
                switch result {
                case .success(let notificationResponse):
                    print("Initial notifications fetched successfully")
                    // Aquí ya no necesitas imprimir las notificaciones,
                    // se agregarán automáticamente al modelo en el ViewModel
                    
                    if(notificationResponse.hayinfo == 1){
                        boolHabiaDatos = true
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
