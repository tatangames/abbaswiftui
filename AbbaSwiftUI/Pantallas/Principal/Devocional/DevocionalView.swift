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
    
    

    var body: some View {
        VStack {
            // Encabezado de los tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) { // Puedes ajustar el espacio entre los botones
                    TabButtonDevocional(title: TextoIdiomaController.localizedString(forKey: "key-mis-planes"), isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButtonDevocional(title: TextoIdiomaController.localizedString(forKey: "key-buscar-planes"), isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButtonDevocional(title: TextoIdiomaController.localizedString(forKey: "key-completados"), isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding()
                .background(temaApp == 1 ? Color.black : Color.white)
            }

            // Contenido de los tabs
            TabView(selection: $selectedTab) {
                TabMisPlanesView()
                    .tag(0)
                
                BuscarView()
                    .tag(1)
                
                FinalizadosView()
                    .tag(2)
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
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(10)
        }
    }
}



struct BuscarView: View {
    var body: some View {
        Text("Contenido de Buscar")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow.opacity(0.1))
    }
}

struct FinalizadosView: View {
    var body: some View {
        Text("Contenido de Finalizados")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red.opacity(0.1))
    }
}

