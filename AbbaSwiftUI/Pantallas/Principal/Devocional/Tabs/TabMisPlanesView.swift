//
//  TabMisPlanesView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 14/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation
import SDWebImageSwiftUI

struct TabMisPlanesView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = TabsMisPlanesViewModel()
    @State private var openLoadingSpinner: Bool = false
    @State private var boolHayDatos: Bool = true
    
    @State private var boolTabs1UnaVez: Bool = true
    
    
    var body: some View {
        ZStack {
            VStack() {
                
                if(boolHayDatos){
                    
                    
                    List(viewModel.misplanesArray) { planes in
                        TabsMisPlanesRow(planes: planes, temaApp: temaApp)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Ajuste para quitar los márgenes laterales
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
                if(boolTabs1UnaVez){
                    boolTabs1UnaVez = false
                    loadTabs1()
                }
                
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
    
    
    private func loadTabs1(){
        openLoadingSpinner = true
        viewModel.tabsMisPlanesRX(idToken: idToken, idCliente: idCliente, idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    print("json \(json)")
                    
                    let _haynfo = json["hayinfo"].int ?? 0
                    
                    let listadoJSON = json["listado"].arrayValue
                    self.viewModel.misplanesArray = listadoJSON.compactMap { itemJSON in
                        if let _idplan = itemJSON["idplan"].int,
                           let _titulo = itemJSON["titulo"].string,
                           let _subtitulo = itemJSON["subtitulo"].string,
                           let _imagen = itemJSON["imagen"].string,
                           let _imagenPortada = itemJSON["imagenportada"].string {
                            return ModeloMisPlanesListado(idPlanes: _idplan, titulo: _titulo, subtitulo: _subtitulo, imagen: _imagen, imagenPortada: _imagenPortada)
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



struct TabsMisPlanesRow: View {
    let planes: ModeloMisPlanesListado
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
                    Text("Este ")
                        .font(.headline)
                        .foregroundColor(.primary)
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

