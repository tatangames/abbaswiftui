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

struct BloqueFechaDevocionalView: View {
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var boolActivarVista: Bool = false
    @State private var urlImagen: String = ""
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = BloqueFechasDevocionalViewModel()
    @StateObject var viewModelCompartir = BloqueFechasCompartirPreguntasViewModel()
    @ObservedObject var settingsVista: GlobalVariablesSettings
    
    @Environment(\.dismiss) var dismiss
    @State private var textToShare: String = ""
    @State private var isShareSheetPresented = false
    @State private var selectedListado: ListadoBloqueFecha?
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    if(boolActivarVista){
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 10) {
                                // Imagen
                                WebImage(url: URL(string: baseUrlImagen + urlImagen))
                                    .resizable()
                                    .indicator(.activity)
                                    .scaledToFit()
                                    .frame(height: 250)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 20)
                                    .clipped()
                                
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) { // Mantenemos spacing: 0 para eliminar espacio entre items
                                        ForEach(viewModel.misplanesArray, id: \.id) { item in
                                            VStack {
                                                Text(item.textopersonalizado)
                                                    .fontWeight(.medium)
                                                    .frame(width: 100, height: 40) // Primero definimos el frame
                                                    .background(selectedListado?.id == item.id ? Color.blue : Color.gray.opacity(0.1))
                                                    .cornerRadius(25)
                                                    .onTapGesture {
                                                        selectedListado = item
                                                    }
                                            }
                                            // Eliminamos el padding(.trailing, 0) ya que no es necesario
                                        }
                                    }
                                    .padding(.horizontal, 20) // Mantenemos solo el padding del ScrollView
                                }
                                .padding(.top, 5)
                                                                
                                // Lista vertical para mostrar los detalles del ítem seleccionado
                                if let listado = selectedListado {
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(listado.detalle, id: \.id) { detalle in
                                            HStack {
                                                Text(detalle.titulo)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(temaApp==1 ? .white : .black)
                                                
                                                Spacer() // Espacio flexible para empujar la imagen a la derecha
                                                
                                                Button(action: {
                                                    // Llama a tu función aquí, por ejemplo:
                                                    obtenerTextoServer(idPlanBlock: detalle.id)
                                                }) {
                                                    Image(systemName: "square.and.arrow.up")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(temaApp==1 ? .white : .black)
                                                        .frame(width: 30, height: 30)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            .padding(.horizontal, 15)
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding(.top, 15)
                            .onAppear {
                                // Selecciona el primer elemento por defecto si existe
                                if let firstItem = viewModel.misplanesArray.first {
                                    selectedListado = firstItem
                                }
                            }
                        }
                    }
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModel.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                .onReceive(viewModelCompartir.$loadingSpinner) { loading in
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-devocional"))
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
            .sheet(isPresented: $isShareSheetPresented) {
                ShareSheetTextoDevocional(items: [textToShare])
            }
            
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    
    private func obtenerTextoServer(idPlanBlock: Int){
        openLoadingSpinner = true
        viewModelCompartir.solicitarPreguntasCompartirRX(idToken: idToken, idCliente: idCliente, idiomaApp: idiomaApp, idBlockDeta: idPlanBlock) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                
                switch success {
                case 1:
                    // pendiente de contestar devocional
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-devocional-pendiente"), tipoColor: .gris)
                case 2:
                    // viene texto
                    
                    let _textoCompleto = json["formatoPregu"].string ?? ""
                    
                    textToShare = _textoCompleto
                    
                    // Llama a la función para compartir el texto
                    // compartirDevo(texto: _textoPreguntas)
                    isShareSheetPresented = true
                case 3:
                    // no hay preguntas disponibles
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-devocional-pendiente"), tipoColor: .gris)
                default:
                    mensajeError()
                }
                
            case .failure(_):
                mensajeError()
            }
        }
    }
    
    
    private func loadData(){
        openLoadingSpinner = true
        
        viewModel.listadoBloqueFechasRX(idToken: idToken, idCliente: idCliente, idiomaApp: idiomaApp, idPlan: settingsVista.selectedPlanIDGlobal) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                
                switch success {
                case 1:
                    
                    let _portada = json["portada"].string ?? ""
                    urlImagen = _portada
                    
                    // Asumiendo que ya obtuviste tu JSON y realizaste el mapeo
                    let listadoJSON = json["listado"].arrayValue
                    
                    let nuevoListado = listadoJSON.compactMap { itemJSON in
                        if let id = itemJSON["id"].int,
                           let idPlanes = itemJSON["id_planes"].int,
                           let fechaInicio = itemJSON["fecha_inicio"].string,
                           let textoPersonalizado = itemJSON["textopersonalizado"].string {
                            
                            let detalleJSON = itemJSON["detalle"].arrayValue
                            let detalles = detalleJSON.compactMap { detalleItem -> DetalleBloqueFecha? in
                                if let detalleId = detalleItem["id"].int,
                                   let idPlanesBloques = detalleItem["id_planes_bloques"].int,
                                   let posicion = detalleItem["posicion"].int,
                                   let redireccionarWeb = detalleItem["redireccionar_web"].int,
                                   let urlLink = detalleItem["url_link"].string,
                                   let titulo = detalleItem["titulo"].string,
                                   let completado = detalleItem["completado"].int {
                                    
                                    return DetalleBloqueFecha(
                                        id: detalleId,
                                        id_planes_bloques: idPlanesBloques,
                                        url_link: urlLink,
                                        redireccionar_web: redireccionarWeb,
                                        completado: completado,
                                        posicion: posicion,
                                        titulo: titulo
                                    )
                                }
                                return nil
                            }
                            
                            return ListadoBloqueFecha(
                                textopersonalizado: textoPersonalizado,
                                detalle: detalles,
                                id: id,
                                fecha_inicio: fechaInicio,
                                id_planes: idPlanes
                            )
                        }
                        return nil
                    }
                    
                    
                    viewModel.misplanesArray = nuevoListado
                    // Selecciona el primer elemento si existe.
                    if let firstItem = viewModel.misplanesArray.first {
                        selectedListado = firstItem
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


struct ShareSheetTextoDevocional: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

