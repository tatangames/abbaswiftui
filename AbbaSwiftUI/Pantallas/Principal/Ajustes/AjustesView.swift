//
//  AjustesView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation


struct AjustesView: View {
    
    @EnvironmentObject var idiomaSettings: IdiomaSettings
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var unaVezPeticion = false
    @State private var hasDatosCargados = false
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = true
    @State private var primerLetra:String = ""
    @State private var nombreUsuario:String = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var showThemeChangeSheet:Bool = false
    @State private var popCerrarSesion:Bool = false
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    @StateObject private var viewModel = AjustesViewModel()
    @State private var boolModalCambioIdioma = false
    @State private var mostrarModal = false
    
        
    @State private var vistaSeleccionada: EnumTipoVistaAjustes?
    
 
    
    var body: some View {
        ZStack {
            VStack {
                if hasDatosCargados {
                    List {
                        
                        // *** PERFIL
                        VStack {
                            HStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                    .overlay(
                                        Text(primerLetra)
                                            .foregroundColor(temaApp == 1 ? .black : .white)
                                            .font(.headline)
                                    )
                                Text(nombreUsuario)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                    .font(.body)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // Alinea el contenido a la izquierda
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                
                                vistaSeleccionada = .perfil
                             
                            }
                            
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                        
                        
                        // *** NOTIFICACIONES
                        VStack {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-notificaciones"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                vistaSeleccionada = .notificaciones
                            }
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        // *** CONTRASEÑA
                        VStack {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-contrasena"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                
                                vistaSeleccionada = .contrasena
                                
                              
                            }
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                        // *** INSIGNIAS POR GANAR
                        VStack {
                            HStack {
                                Image(systemName: "rosette")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-insignias-por-ganar"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                vistaSeleccionada = .insignias
                            }
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                        // *** IDIOMA
                        VStack {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-idioma"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                boolModalCambioIdioma = true
                            }
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                        // *** TEMAS
                        VStack {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-temas"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                showThemeChangeSheet.toggle()
                            }
                            LineaHorizontal(altura: 0.3, espaciado: 40, temaApp: temaApp)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                        // *** CERRAR SESION
                        VStack {
                            HStack {
                                Image(systemName: "power")
                                    .foregroundColor(.gray)
                                Text(TextoIdiomaController.localizedString(forKey: "key-cerrar-sesion"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.body)
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                            .padding()
                            .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                            .onTapGesture {
                                popCerrarSesion = true
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(temaApp == 1 ? Color("coscurov1") : .white)
                        
                        
                        
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6)) // fondo de pantalla total
                }
            }
            .onAppear {
                
                if(!unaVezPeticion){
                    unaVezPeticion = true
                    viewModel.fetchUserData(idToken: idToken, idCliente: idCliente) { result in
                        switch result {
                        case .success(let json):
                            
                            let success = json["success"].int ?? 0
                            switch success {
                            case 1:
                                // informacion del usuario
                                
                                let _nombre = json["nombre"].string ?? ""
                                let _apellido = json["apellido"].string ?? ""
                                
                                if !_nombre.isEmpty {
                                    primerLetra = String(_nombre.prefix(1))
                                }
                                nombreUsuario = "\(_nombre) \(_apellido)"
                                
                                hasDatosCargados = true
                            default:
                                mensajeError()
                            }
                            
                        case .failure(_):
                            mensajeError()
                        }
                    }
                }
                
            }
            .sheet(isPresented: $showThemeChangeSheet) {
                ThemeChangeView(scheme: colorScheme)
                    .presentationDetents([.height(410)])
                    .presentationBackground(.clear)
            }
            
            .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-ajustes"))
            
            if popCerrarSesion {
                PopImg2BtnView(isActive: $popCerrarSesion, imagen: .constant("infocolor"), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-cerrar-sesion")), txtCancelar: .constant(TextoIdiomaController.localizedString(forKey: "key-no")),
                               txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-si")),
                               cancelAction: {popCerrarSesion = false},
                               acceptAction: {
                    idToken = ""
                    idCliente = ""
                    vistaSeleccionada = .cerrarsesion
                    
                }).zIndex(1)
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
        .sheet(isPresented: $boolModalCambioIdioma) {
            CambiarIdiomaModal(
                idiomaSeleccionado: $idiomaApp,
                cambiarIdioma: { nuevoIdioma in
                    //  idiomaApp = nuevoIdioma
                    idiomaSettings.idioma = nuevoIdioma
                    
                }
            )
        }
        
        .fullScreenCover(item: $vistaSeleccionada) { view in
            switch view {
            case .perfil:
                PerfilView()
            case .contrasena:
                ContrasenaAjustesView()
            case .notificaciones:
                NotificacionesAjustesView()
            case .insignias:
                InsigniasPorGanarAjustesView()
            case .cerrarsesion:
                LoginPresentacionView()
            }
        }
    }
    
    
    
    func mensajeError(){
        
    }
    
    
    func cambiarIdioma(nuevoIdioma: String) {
        // Aquí va la lógica para cambiar el idioma
        print("Idioma cambiado a: \(nuevoIdioma)")
    }
    
}
