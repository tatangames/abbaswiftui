//
//  TextoDevocionalView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 21/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation

struct TextoDevocionalView: View {
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    
    @AppStorage(DatosGuardadosKeys.tamanoLetra) private var fontSize:Int = 20
    @AppStorage(DatosGuardadosKeys.tipoLetra) private var tipoLetra:Int = 0
    
    
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = TextoDevocionalViewModel()
    @ObservedObject var settingsVista: GlobalVariablesSettings
    
    @Environment(\.dismiss) var dismiss
    
    @State private var textoDevocional: String = ""
    @State private var activarVista: Bool = false
    
    
    @State private var showModal = false
    
    var modeloLetra: [ModeloPickerLetra] = [
        ModeloPickerLetra(id: 0, titulo: "Noto Sans Light"),
        ModeloPickerLetra(id: 1, titulo: "Noto Sans Medium"),
        ModeloPickerLetra(id: 2, titulo: "Times New Roman"),
        ModeloPickerLetra(id: 3, titulo: "Recolecta Medium"),
        ModeloPickerLetra(id: 4, titulo: "Recolecta Regular")
    ]
    
    
    @State private var selectedPickerLetra: ModeloPickerLetra?
    
    
    
   
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    
                    if(activarVista){
                        CustomWebView(htmlContent: textoDevocional)
                               .onAppear {
                                   // Lógica adicional si es necesario
                               }
                      
                        
                    }
                    
                    
                }.onAppear {
                    loadData()
                }
                .onReceive(viewModel.$loadingSpinner) { loading in
                    openLoadingSpinner = loading
                }
                
                
                // Botón flotante en la esquina inferior izquierda
                VStack {
                    Spacer() // Empujar el contenido hacia abajo
                    HStack {
                        Spacer() // Empujar el botón hacia la derecha
                        
                        Button(action: {
                            // Acción del botón
                            showModal = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 16) // Mover el botón hacia adentro desde el borde derecho
                    }
                    .padding(.bottom, 16) // Ajustar el margen desde el fondo
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
            .sheet(isPresented: $showModal) {
                AjustarFontSizeView(
                                fontSize: $fontSize,
                                selectedPickerLetra: $selectedPickerLetra,
                                tipoLetra: $tipoLetra,
                                adjustFont: adjustFont // Pasar la función aquí
                            )
                    .presentationDetents([.height(300)]) // Ajusta el tamaño del modal
                    .presentationDragIndicator(.visible)
            }
            
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, // toolbar
                                                titleColor: .black))
    }
    
    
    
    private func loadData(){
        openLoadingSpinner = true
        viewModel.infoTextoDevocionalRX(idToken: idToken, idCliente: idCliente, idBlockDeta: settingsVista.selectedIdBlockDeta ,idiomaApp: idiomaApp) { result in
            switch result {
            case .success(let json):
                
                let success = json["success"].int ?? 0
                
                switch success {
                case 1:
                    
                    let _redireccion = json["redireccionar"].int ?? 0
                    let _iddevobiblia = json["iddevobiblia"].int ?? 0
                    let _devocional = json["devocional"].string ?? ""
                    let _redirecweb = json["redirecweb"].int ?? 0
                    let _urllink = json["urllink"].string ?? ""
                    
                    textoDevocional = _devocional
                    
                    activarVista = true
                    
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
    
    func adjustFont() {
           // Tu lógica para ajustar la fuente aquí
           print("Ajustar fuente: \(fontSize), tipo: \(tipoLetra)")
         
    }
    
}



struct AjustarFontSizeView: View {
    @Binding var fontSize: Int
    @Binding var selectedPickerLetra: ModeloPickerLetra?
    @Binding var tipoLetra: Int
    
    // Agrega la propiedad para el closure
    var adjustFont: () -> Void
    
    @State private var selectedFont: Int? = nil
    
    init(fontSize: Binding<Int>, selectedPickerLetra: Binding<ModeloPickerLetra?>, tipoLetra: Binding<Int>, adjustFont: @escaping () -> Void) {
          self._fontSize = fontSize
          self._selectedPickerLetra = selectedPickerLetra
          self._tipoLetra = tipoLetra
          self.adjustFont = adjustFont // Asignar el closure
          self._selectedFont = State(initialValue: tipoLetra.wrappedValue)
      }
    
    var modeloLetra: [ModeloPickerLetra] = [
        ModeloPickerLetra(id: 0, titulo: "Noto Sans Light"),
        ModeloPickerLetra(id: 1, titulo: "Noto Sans Medium"),
        ModeloPickerLetra(id: 2, titulo: "Time New Roman"),
        ModeloPickerLetra(id: 3, titulo: "Recolecta Medium"),
        ModeloPickerLetra(id: 4, titulo: "Recolecta Regular")
    ]
    
    var body: some View {
        VStack {
            
            
            // Botones para aumentar o disminuir el tamaño de la letra
            VStack(alignment: .leading) { // Alinear el contenido a la izquierda
                Text(TextoIdiomaController.localizedString(forKey: "key-tamano-de-letra"))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .padding(.leading) // Espaciado hacia la izquierda
                
                HStack(spacing: 10) { // Espacio entre los botones
                    Button(action: {
                        if fontSize > 15 {
                            fontSize -= 1
                            adjustFont()
                        }
                    }) {
                        Text("A-") // Texto del botón
                            .font(.system(size: 16)) // Cambiar a una fuente más pequeña
                            .foregroundColor(.black)
                            .padding() // Ajustar padding
                            .frame(maxWidth: .infinity) // Ocupa todo el ancho disponible
                            .background(Color.gray.opacity(0.2)) // Fondo gris
                            .cornerRadius(10) // Esquinas redondeadas
                    }
                    
                    Button(action: {
                        if fontSize < 35 {
                            fontSize += 1
                            adjustFont()
                            
                        }
                    }) {
                        Text("A+") // Texto del botón
                            .font(.system(size: 16)) // Cambiar a una fuente más pequeña
                            .foregroundColor(.black)
                            .padding() // Ajustar padding
                            .frame(maxWidth: .infinity) // Ocupa todo el ancho disponible
                            .background(Color.gray.opacity(0.2)) // Fondo gris
                            .cornerRadius(10) // Esquinas redondeadas
                    }
                }
                
                
                
                Text(TextoIdiomaController.localizedString(forKey: "key-fuente"))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    .padding(.leading) // Espaciado hacia la izquierda
                    .padding(.top, 5)
                
                
                Menu {
                    ForEach(modeloLetra) { modelo in
                        Button(action: {
                            tipoLetra = modelo.id
                            selectedFont = modelo.id // Actualiza el ID de la fuente seleccionada
                        }) {
                            Text(modelo.titulo)
                                .foregroundStyle(Color.black)
                        }
                    }
                } label: {
                    HStack {
                        // Mostrar el nombre de la fuente seleccionada o un texto predeterminado
                        Text(selectedFont.map { modeloLetra[$0].titulo } ?? TextoIdiomaController.localizedString(forKey: "key-seleccionar-opcion"))
                            .foregroundColor(Color.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                .padding() // Padding general para el HStack
            }
            .padding()
        }
        .padding()
    }
}


struct ModeloPickerLetra: Identifiable {
    var id: Int
    var titulo: String
}
