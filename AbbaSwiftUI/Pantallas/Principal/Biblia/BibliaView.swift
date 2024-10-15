//
//  BibliaView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI

struct BibliaView: View {
    
    @EnvironmentObject var idiomaSettings: IdiomaSettings
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var toastViewModel = ToastViewModel()
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @State private var openLoadingSpinner: Bool = false
    @State private var unaVezPeticion = false
    
    var body: some View {
        ZStack {
                VStack {
                    List {
                        
                        
                        VStack {
                            VStack(alignment: .leading) {
                                Text(TextoIdiomaController.localizedString(forKey: "key-biblia"))
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(temaApp == 1 ? Color.white : Color.black)
                                
                                
                                Image(idiomaApp == 1 ? "obra" : "obraen")
                               .resizable()
                               .aspectRatio(contentMode: .fit) // Ajusta cómo se mostrará la imagen
                               .frame(maxWidth: .infinity, maxHeight: 200) // Ajusta el alto según tus necesidades
                               .padding(.top, 45)
        
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // Asegura que ocupe todo el ancho
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(temaApp == 1 ? Color("coscurov1") : .white)
                        )
                        .padding([.horizontal, .top], 10)
                        .listRowInsets(EdgeInsets()) // Elimina los insets de las celdas si se usa dentro de una lista
                        .listRowSeparator(.hidden) // Oculta el separador de la celda si se usa dentro de una lista
                        .listRowBackground(Color.clear)
                        
                        
                        
                        
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6)) // fondo de pantalla total
                }
                .onAppear {
                    if(!unaVezPeticion){
                        unaVezPeticion = true
                    }
                }
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-ajustes"))
                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
            }
            .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                toastViewModel.customToast
            })
    }
    
}

#Preview {
    BibliaView()
}
