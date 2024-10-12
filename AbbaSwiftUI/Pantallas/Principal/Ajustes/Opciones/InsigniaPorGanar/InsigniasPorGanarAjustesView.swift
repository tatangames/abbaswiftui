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
import SDWebImageSwiftUI

struct InsigniasPorGanarAjustesView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    
    @StateObject private var toastViewModel = ToastViewModel()
    @State private var openLoadingSpinner: Bool = false
    @StateObject var viewModel = InsigniasPorGanarViewModel()
    
    @State private var boolHayDatos: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack() {
                    if(boolHayDatos){
                        List(viewModel.insignias) { insignia in
                            InsigniaPorGanarRow(insignia: insignia, temaApp: temaApp)
                            
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                        .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6))
                    }else{
                        VStack {
                            VStack {
                                Image("insignias")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 15)
                                
                                HStack {
                                    Spacer()
                                    Text(TextoIdiomaController.localizedString(forKey: "key-todas-las-insignias-ganadas"))
                                        .foregroundColor(temaApp == 1 ? .white : .black)
                                        .bold()
                                    Spacer()
                                }
                                .padding(.top, 25)
                            }
                            .padding()
                            .background(temaApp == 1 ? Color("coscurov1") : Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                            
                            Spacer() // Esto empuja la tarjeta hacia la parte superior
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 20)
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-insignias"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
            }
            .background(temaApp == 1 ? Color.black : Color.white) // fondo de pantalla
            .toast(isPresenting: $toastViewModel.showToastBool, duration: 3, tapToDismiss: false) {
                toastViewModel.customToast
            }
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    private func loadData() {
        openLoadingSpinner = true
        viewModel.insigniasPorGanarRX(idToken: idToken, idCliente: idCliente, idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    let _haynfo = json["hayinfo"].int ?? 0
                    
                    let listadoJSON = json["listado"].arrayValue
                    self.viewModel.insignias = listadoJSON.compactMap { insigniaJSON in
                        if let id = insigniaJSON["id"].int,
                           let imagen = insigniaJSON["imagen"].string,
                           let titulo = insigniaJSON["titulo"].string,
                           let descripcion = insigniaJSON["descripcion"].string {
                            return ModeloInsigniasListado(id: id, imagen: imagen, titulo: titulo, descripcion: descripcion)
                        }
                        return nil
                    }
                    
                    if(_haynfo==0){boolHayDatos=false}
                    
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


struct InsigniaPorGanarRow: View {
    let insignia: ModeloInsigniasListado
    let temaApp: Int
    
    var body: some View {
        VStack {
            WebImage(url: URL(string: baseUrlImagen + insignia.imagen))
                .resizable()
                .indicator(.activity)
                .scaledToFit()
                .frame(height: 150)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading) {
                Text(insignia.titulo)
                    .font(.headline)
                    .foregroundColor(temaApp == 1 ? Color.white : Color.black)
                
                // Muestra el texto completo de la descripción
                Text(insignia.descripcion)
                    .font(.subheadline)
                    .foregroundColor(temaApp == 1 ? .white : .black)
                    .padding(.top, 8)
            }
        }
        .padding()
        .listRowInsets(EdgeInsets()) // Elimina los insets de las celdas si se usa dentro de una lista
        .listRowSeparator(.hidden) // Oculta el separador de la celda si se usa dentro de una lista
        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
    }
}
