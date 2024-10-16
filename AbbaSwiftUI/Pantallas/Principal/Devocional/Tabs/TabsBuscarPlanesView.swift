//
//  TabsBuscarPlanesView.swift
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




struct TabsBuscarPlanesView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = TabsBuscarPlanesViewModel()
    @State private var openLoadingSpinner: Bool = false
    
    @State private var boolTabs1UnaVez: Bool = true
    @State private var boolActivarVista: Bool = false
    @State private var boolCambiarVista:Bool = false
    @ObservedObject var settingsVista: TabsDevocionalSettings
    
    var body: some View {
        ZStack {
            VStack {
                
                if(boolActivarVista){
                    
                    if(viewModel.misplanesArray.isEmpty){
                        
                        VStack {
                            VStack {
                                Image("libroa")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 15)
                                
                                HStack {
                                    Spacer()
                                    Text(TextoIdiomaController.localizedString(forKey: "key-todos-los-planes"))
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
                        
                        
                    }else{
                        List(viewModel.misplanesArray) { planes in
                            TabsBuscarPlanesRow(planes: planes, temaApp: temaApp)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .onTapGesture {
                                    settingsVista.selectedBuscarPlanID = planes.id
                                    boolCambiarVista = true
                                }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                        .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6))
                    }
                }
                
            }.onAppear {
                if(boolTabs1UnaVez){
                    boolTabs1UnaVez = false
                    loadTabs()
                }
            }
            .fullScreenCover(isPresented: $boolCambiarVista) {
                InformacionPlanView(settings: settingsVista)
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
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .background(temaApp == 1 ? .black : .white)

    }
    
    
    private func loadTabs(){
        openLoadingSpinner = true
        viewModel.tabsBuscarPlanesRX(idToken: idToken, idCliente: idCliente, idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                              
                    let listadoJSON = json["listado2"].arrayValue
                    self.viewModel.misplanesArray = listadoJSON.compactMap { itemJSON in
                        if let _id = itemJSON["id"].int,
                           let _titulo = itemJSON["titulo"].string,
                           let _imagen = itemJSON["imagen"].string{
                            return ModeloBuscarPlanesListado(id: _id, titulo: _titulo, imagen: _imagen)
                        }
                        return nil
                    }
                    
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

struct TabsBuscarPlanesRow: View {
    let planes: ModeloBuscarPlanesListado
    let temaApp: Int

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                WebImage(url: URL(string: baseUrlImagen + planes.imagen))
                    .resizable()
                    .indicator(.activity)
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical, 8) // Espaciado vertical de la imagen

                VStack(alignment: .leading, spacing: 0) {
                    Text(planes.titulo)
                        .font(.headline)
                        .foregroundColor(temaApp == 1 ? .white : .black)
                    Spacer() // Asegura que el texto esté en la parte superior
                }
                .frame(maxHeight: .infinity, alignment: .top) // Alinea el VStack en la parte superior

                Spacer()
            }
            .padding(.vertical, 8) // Ajusta el espaciado general del HStack
            .padding(.leading, 10) // Añadir espacio al borde izquierdo
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(temaApp == 1 ? Color("coscurov1") : .white)
            )
        }
        .padding([.horizontal, .top], 10)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

