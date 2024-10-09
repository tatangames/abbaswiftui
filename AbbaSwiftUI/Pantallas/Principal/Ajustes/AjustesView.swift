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
    @State private var showThemeChangeSheet = false
    
    // Variable para almacenar el contenido del toast
    @State private var customToast: AlertToast = AlertToast(displayMode: .banner(.slide), type: .regular, title: "", style: .style(backgroundColor: .clear, titleColor: .white, subTitleColor: .blue, titleFont: .headline, subTitleFont: nil))
    
    
    @StateObject private var viewModel = AjustesViewModel()
    
    


      var body: some View {
          NavigationStack {
              ZStack{
                  VStack {
                      if(hasDatosCargados){
                          List {
                              HStack {
                                  Text(TextoIdiomaController.localizedString(forKey: "key-ajustes"))
                                      .font(.custom("LiberationSans-Bold", size: 26))
                                      .foregroundColor(temaApp == 1 ? .black : .black)
                                  
                                  Spacer()
                              }
                              
                              
                              // Primera celda: Usuario
                              HStack {
                                  Circle()
                                      .frame(width: 40, height: 40)
                                      .foregroundColor(temaApp == 1 ? .black : .white)
                                      .overlay(
                                          Text(primerLetra)
                                              .foregroundColor(temaApp == 1 ? .white : .black)
                                              .font(.headline)
                                      )
                                  Text(nombreUsuario)
                                      .foregroundColor(temaApp == 1 ? .black : .white)
                                      .font(.body)
                                      .padding(.leading, 8)
                              }
                              .padding(.vertical, 8)
                              
                              // Tercera celda: Opción de Notificaciones
                              HStack {
                                  Image(systemName: "bell.fill")
                                      .foregroundColor(.gray)
                                  Text("Notificaciones")
                                      .padding(.leading, 8)
                                  Spacer()
                              }
                              .padding(.vertical, 8)
                              
                              // Cuarta celda: Opción de Contraseña
                              HStack {
                                  Image(systemName: "key.fill")
                                      .foregroundColor(.gray)
                                  Text("Cambiar Contraseña")
                                      .padding(.leading, 8)
                                  Spacer()
                              }
                              .padding(.vertical, 8)
                              
                       
                        
                              
                              HStack {
                                     Image(systemName: "key.fill")
                                         .foregroundColor(.gray)
                                     Text("Temas")
                                         .padding(.leading, 8)
                                     Spacer()
                                 }
                                 .padding(.vertical, 8)
                                 .contentShape(Rectangle()) // Asegúrate de que toda el área sea clickeable
                                 .onTapGesture {
                                     showThemeChangeSheet.toggle() // Muestra la hoja de temas
                                 }
                              
                              
                           
                          }
                          .listStyle(InsetGroupedListStyle())
                          .scrollContentBackground(.hidden)
                          .background(temaApp == 1 ? .black : .white)
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
                  .navigationTitle("Ajustes")
                  .toolbar {
                      ToolbarItem(placement: .principal) {
                          Text("Configuración")
                              .font(.headline)
                              .foregroundColor(colorScheme == .dark ? .white : .black)
                      }
                  }
                  .sheet(isPresented: $showThemeChangeSheet) {
                      ThemeChangeView(scheme: colorScheme)
                          .presentationDetents([.height(410)])
                          .presentationBackground(.clear)
                  }
                  if openLoadingSpinner {
                      LoadingSpinnerView()
                          .transition(.opacity) // Transición de opacidad
                          .zIndex(10)
                  }
              }.onReceive(viewModel.$loadingSpinner) { loading in
                  openLoadingSpinner = loading
              }
          }
      }
    
    
    /*var body: some View {
        
        ZStack{
            VStack {
                if(hasDatosCargados){
                    
                    List {
                        HStack {
                            Text(TextoIdiomaController.localizedString(forKey: "key-ajustes"))
                                .font(.custom("LiberationSans-Bold", size: 26))
                                .foregroundColor(temaApp == 1 ? .black : .black)
                            
                            Spacer()
                        }
                        
                        
                        // Primera celda: Usuario
                        HStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(temaApp == 1 ? .black : .white)
                                .overlay(
                                    Text(primerLetra)
                                        .foregroundColor(temaApp == 1 ? .white : .black)
                                        .font(.headline)
                                )
                            Text(nombreUsuario)
                                .foregroundColor(temaApp == 1 ? .black : .white)
                                .font(.body)
                                .padding(.leading, 8)
                        }
                        .padding(.vertical, 8)
                        
                        // Tercera celda: Opción de Notificaciones
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.gray)
                            Text("Notificaciones")
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Cuarta celda: Opción de Contraseña
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.gray)
                            Text("Cambiar Contraseña")
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Opción de Temas
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.gray)
                            Text("Temas")
                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .onTapGesture {
                                // Aquí colocas la acción que deseas realizar cuando se hace clic en la opción de "Temas"
                            showThemeChangeSheet = true// Por ejemplo, una función para cambiar el tema
                            }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(temaApp == 1 ? .black : .white)
                    
                    
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
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity) // Transición de opacidad
                    .zIndex(10)
            }
        } .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .sheet(isPresented: $showThemeChangeSheet) {
                    ThemeChangeView(scheme: scheme)
                }
    }*/

    
    func mensajeError(){
        self.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
    }
    
    // Función para configurar y mostrar el toast
    func showCustomToast(with mensaje: String, tipoColor: ToastColor) {
        let titleColor = tipoColor.color
        customToast = AlertToast(
            displayMode: .banner(.pop),
            type: .regular,
            title: mensaje,
            subTitle: nil,
            style: .style(
                backgroundColor: titleColor,
                titleColor: Color.white,
                subTitleColor: Color.blue,
                titleFont: .headline,
                subTitleFont: nil
            )
        )
        showToastBool = true
    }
}

