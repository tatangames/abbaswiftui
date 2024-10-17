//
//  DevocionalView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI

struct DevocionalView: View {
    @EnvironmentObject var idiomaSettings: IdiomaSettings
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
 
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = true
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = AjustesViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    
    @State private var selectedTab = 0
    
    @ObservedObject var settingsGlobal: GlobalVariablesSettings
    
    
    
    var body: some View {
        VStack {
            // Encabezado de los tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) { // Puedes ajustar el espacio entre los botones
                    
                    TabButtonDevocional(title: TextoIdiomaController.localizedString(forKey: "key-mis-planes"), isSelected: selectedTab == 0, temaApp: temaApp) {
                        selectedTab = 0
                    }
                    TabButtonDevocional(title: TextoIdiomaController.localizedString(forKey: "key-buscar-planes"), isSelected: selectedTab == 1,temaApp: temaApp) {
                        selectedTab = 1
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(temaApp == 1 ? Color.black : Color.white)
                )
                .padding(.horizontal)
            }

            // Contenido de los tabs
            TabView(selection: $selectedTab) {
                TabMisPlanesView(settingsGlobal: settingsGlobal)
                    .tag(0)
                
                TabsBuscarPlanesView(settingsGlobal: settingsGlobal)
                    .tag(1)
                               
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Oculta los indicadores predeterminados
        }
        .background(temaApp == 1 ? Color.black : Color(UIColor.systemGray6)) // fondo de pantalla total
        
    }
}

// Vista personalizada para cada botón de tab
struct TabButtonDevocional: View {
    var title: String
    var isSelected: Bool
    var temaApp: Int
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : (temaApp == 1 ? .gray : .blue)) // Cambia el color del texto según el tema
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        isSelected ? (temaApp == 1 ? Color.gray : Color.blue) : Color.clear // Cambia el color de fondo según el tema y si está seleccionado
                    )
                    .cornerRadius(10)
        }
    }
}


