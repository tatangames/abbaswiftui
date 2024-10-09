//
//  ThemeChangeView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @Namespace private var animation
    @State private var circleOffset: CGSize

    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        // Establecer el valor inicial de circleOffset basado en el tema
        self._circleOffset = .init(initialValue: isDark ? CGSize(width: 30, height: -25) : CGSize(width: 150, height: -150))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(currentTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    Rectangle()
                        .overlay {
                            // Círculo principal para la luna
                            Circle()
                                .frame(width: 150, height: 150)
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                            
                            // Círculo secundario para el recorte (sombra) de la luna
                            Circle()
                                .frame(width: 120, height: 120) // Tamaño del recorte para la sombra de la luna
                                .offset(x: circleOffset.width + 40, y: circleOffset.height) // Ajuste de posición para dar forma de cuarto de luna
                                .blendMode(.destinationOut)
                        }
                }
                .animation(.easeInOut, value: circleOffset) // Animación suave para cambiar entre sol y luna
            
            Text(TextoIdiomaController.localizedString(forKey: "key-selecciona-un-tema"))
                .font(.title2.bold())
                .foregroundColor(temaApp == Theme.dark.rawValue ? .white : .black)

                .padding(.top, 25)
            
            HStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Text(theme.localizedName)
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background {
                            if temaApp == theme.rawValue {
                                Capsule()
                                    .fill(Color.themeBG)
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        }
                        .animation(.snappy, value: temaApp)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            temaApp = theme.rawValue
                            updateOffset(for: theme)
                        }
                }
            }
            .padding(3)
            .background(selectionBackgroundColor, in: Capsule())
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 410)
        .background(backgroundColor) // COLOR PERSONALIZADO// COLOR UNIVERSAL ANY / DARK | DE ASSET
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 15)
        .environment(\.colorScheme, scheme)
        .onAppear {
            // Actualizar circleOffset al aparecer la vista según el tema seleccionado
            updateOffset(for: currentTheme)
        }
    }
    
    private func updateOffset(for theme: Theme) {
        withAnimation(.easeInOut) {
            if theme == .light {
                circleOffset = CGSize(width: 150, height: -150) // Sol
            } else {
                circleOffset = CGSize(width: 30, height: -25) // Luna
            }
        }
    }
    
    private var currentTheme: Theme {
          return Theme(rawValue: temaApp) ?? .light
      }
    
    // Propiedad computada para el color de fondo
       private var backgroundColor: Color {
           switch currentTheme {
           case .light:
               return Color.white // Color de fondo para el tema claro
           case .dark:
               return Color(red: 30/255, green: 30/255, blue: 39/255)// Color de fondo para el tema oscuro
           }
       }
       
       // Propiedad computada para el color de fondo de la barra de selección
       private var selectionBackgroundColor: Color {
           switch currentTheme {
           case .light:
               return Color.primary.opacity(0.06) // Color de fondo para la barra de selección en tema claro
           case .dark:
               return Color.gray.opacity(0.4) // Color de fondo para la barra de selección en tema oscuro
           }
       }
}


enum Theme: Int, CaseIterable {
    case light = 0
    case dark = 1
    
    // Nombre localizado del tema
    var localizedName: String {
        switch self {
        case .light:
            return TextoIdiomaController.localizedString(forKey: "key-light")
        case .dark:
            return TextoIdiomaController.localizedString(forKey: "key-dark")
        }
    }
    
    // Color correspondiente al tema
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .light:
            return .sun // COLORES DE ASSET
        case .dark:
            return .moon // COLORES DE ASSET
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
