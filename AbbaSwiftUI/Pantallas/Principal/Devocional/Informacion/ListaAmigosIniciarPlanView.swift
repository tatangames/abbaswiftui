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

struct Amigo {
    var id: Int
    var iduserFila: Int
}

struct ListaAmigosIniciarPlanView: View {
        
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = true
    @State private var selectedFriendIDs: [ModeloListaAmigosAceptadosListado] = []
    @State private var popIniciarPlan: Bool = false
    @State private var popAmigosSonRequeridos: Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = ListaAmigosIniciarPlanViewModel()
    @StateObject var viewModelIniciar = ListaAmigosIniciarPlanEnviarViewModel()
    @ObservedObject var settingsVista: GlobalVariablesSettings
    
    @Environment(\.dismiss) var dismiss
 
    // para cerrar tambien ventana informacionPlanView
    @Binding var boolInicioPlanConAmigos: Bool
        
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack() {
                    if(viewModel.misAmigosArray.isEmpty){
                        VStack {
                            VStack {
                                Image("amigos")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding(.top, 15)
                                
                                HStack {
                                    Spacer()
                                    Text(TextoIdiomaController.localizedString(forKey: "key-amigos-requeridos"))
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
                                                
                        List(viewModel.misAmigosArray) { amigo in
                            let isSelected = selectedFriendIDs.contains(where: { $0.id == amigo.id })
                            
                            TabsMisAmigosIniciarPlanRow(
                                amigos: amigo,
                                temaApp: temaApp,
                                isSelected: isSelected  // Comprueba si el amigo está en el array seleccionado
                            )
                            .onTapGesture {
                                if isSelected {
                                   // Si el amigo está seleccionado, lo quita
                                   selectedFriendIDs.removeAll { $0.id == amigo.id }
                               } else {
                                   // Si no está seleccionado, lo añade
                                   selectedFriendIDs.append(amigo) // Asegúrate de que 'amigo' sea de tipo 'ModeloListaAmigosAceptadosListado'
                               }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Ajuste para quitar los márgenes laterales
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                        .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6))
                        
                        Button(action: {
                            if selectedFriendIDs.isEmpty {
                                popAmigosSonRequeridos = true
                            }else{
                                popIniciarPlan = true
                            }
                        }) {
                            Text(TextoIdiomaController.localizedString(forKey: "key-iniciar-plan"))
                                .font(.headline)
                                .foregroundColor(temaApp == 1 ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(temaApp == 1 ? .white : Color("cazulv1"))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16) // Añade espaciado lateral
                        .padding(.bottom, 16)
                        .opacity(1.0)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                    }
                    
                    
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModel.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                
                if popIniciarPlan {
                    PopImg2BtnView(isActive: $popIniciarPlan, imagen: .constant("infocolor"), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-iniciar-plan")), txtCancelar: .constant(TextoIdiomaController.localizedString(forKey: "key-no")),
                                   txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-si")),
                                   cancelAction: {popIniciarPlan = false},
                                   acceptAction: {
                        iniciarPlanAmigos()
                    }).zIndex(1)
                }
                                
                if popAmigosSonRequeridos {
                    PopImg1BtnView(isActive: $popAmigosSonRequeridos, imagen: .constant("amigos"), bLlevaTitulo: .constant(false), titulo: .constant(""), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-amigos-requeridos")), txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-aceptar")), acceptAction: {})
                        .zIndex(1)
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-amigos"))
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
            .onReceive(viewModelIniciar.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    private func iniciarPlanAmigos(){
       openLoadingSpinner = true
        viewModelIniciar.iniciarPlanAmigosRX(idToken: idToken, idPlan: settingsVista.selectedPlanIDGlobal, idCliente: idCliente, idiomaApp: idiomaApp, selectedFriends: selectedFriendIDs) { result in
            switch result {
            case .success(let json):
                             
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    salir()
                case 2:
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
        boolInicioPlanConAmigos = true
        dismiss()
    }
    
    private func loadData(){
        openLoadingSpinner = true
        viewModel.listaAmigosAceptadosRX(idToken: idToken, idCliente: idCliente) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    let listadoJSON = json["listado"].arrayValue
                    viewModel.misAmigosArray = listadoJSON.compactMap { itemJSON in
                        if let _id = itemJSON["id"].int,
                           let _userEnvia = itemJSON["id_usuario_envia"].int,
                           let _userRecibe = itemJSON["id_usuario_recibe"].int,
                           let _idUsuario = itemJSON["idusuario"].int,
                           let _nombre = itemJSON["nombre"].string,
                           let _iglesia = itemJSON["iglesia"].string,
                           let _correo = itemJSON["correo"].string,
                           let _pais = itemJSON["pais"].string,
                           let _hayimagen = itemJSON["hayimagen"].int {
                            
                            // Permitir que `imagen` sea opcional
                            let _imagen = itemJSON["imagen"].string ?? ""
                            
                            return ModeloListaAmigosAceptadosListado(id: _id, idUserEnvia: _userEnvia, idUserRecibe: _userRecibe, idUsuario: _idUsuario, nombre: _nombre, iglesia: _iglesia, correo: _correo, pais: _pais, hayimagen: _hayimagen, imagen: _imagen)
                        }
                        return nil
                    }
                                        
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

struct TabsMisAmigosIniciarPlanRow: View {
    let amigos: ModeloListaAmigosAceptadosListado
    let temaApp: Int
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    // Imagen de perfil
                    if amigos.hayimagen == 0 {
                        Image("perfil")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        WebImage(url: URL(string: baseUrlImagen + amigos.imagen))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    
                    // Nombre del amigo
                    Text(amigos.nombre)
                        .font(.headline)
                        .foregroundColor(temaApp == 1 ? .white : .black)
                }
                .padding(.top, 10)
                
                // Información adicional (país, correo, iglesia)
                VStack(alignment: .leading, spacing: 4) { // Alineación a la izquierda
                    HStack(spacing: 4) {
                        Image(systemName: "network") // Icono de bandera
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        
                        Text(amigos.pais)
                            .font(.subheadline)
                            .foregroundColor(temaApp == 1 ? .white : .black)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "envelope") // Icono de correo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        
                        Text(amigos.correo)
                            .font(.subheadline)
                            .foregroundColor(temaApp == 1 ? .white : .black)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin") // Icono de iglesia
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        
                        Text(amigos.iglesia)
                            .font(.subheadline)
                            .foregroundColor(temaApp == 1 ? .white : .black)
                    }
                }
                .padding(.top, 5)
            }
            
            Spacer() // Para empujar el contenido hacia la izquierda
            
            // Imagen de verificación a la derecha
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24) // Ajusta el tamaño del checkmark
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(temaApp == 1 ? Color("coscurov1") : .white)
        )
        .padding([.horizontal, .top], 10)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
