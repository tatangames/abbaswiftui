//
//  StructReutilizable.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import Foundation
import SwiftUI
import AlertToast

// utilizado en login (ejemplo)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// ocultar teclado
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// utilizado en login (ejemplo)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// Animacion cuando el boton es presionado
struct NoOpacityChangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1.0) // Mantener la opacidad al 100% incluso cuando se presiona
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Ejemplo de escala para indicar que está presionado
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}



struct RadioButton: View {
    let id: Int
    let label: String
    @Binding var isSelected: Int
    
    var body: some View {
        Button(action: {
            isSelected = id
        }) {
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected == id {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10) // Círculo más pequeño
                    }
                }
                Text(label)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CustomTextField: View {
    let labelKey: String
    let isDarkMode: Bool
    @Binding var text: String
    let maxLength: Int
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                TextField(TextoIdiomaController.localizedString(forKey: labelKey), text: $text)
                    .keyboardType(keyboardType)
                    .onChange(of: text) { newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.bottom, 0)
                
                // Línea subrayada
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(isDarkMode ? .white : .gray)
            }
        }
    }
}


struct CustomPasswordField: View {
    let labelKey: String
    let isDarkMode: Bool
    @Binding var password: String
    let maxLength: Int
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isPasswordVisible {
                    TextField(TextoIdiomaController.localizedString(forKey: labelKey), text: $password)
                        .onChange(of: password) { newValue in
                            if newValue.count > maxLength {
                                password = String(newValue.prefix(maxLength))
                            }
                        }
                        .foregroundColor(isDarkMode ? .white : .black)
                        .autocapitalization(.none) // Evitar que la contraseña se autocorrija
                } else {
                    SecureField(TextoIdiomaController.localizedString(forKey: labelKey), text: $password)
                        .onChange(of: password) { newValue in
                            if newValue.count > maxLength {
                                password = String(newValue.prefix(maxLength))
                            }
                        }
                        .foregroundColor(isDarkMode ? .white : .black)
                        .autocapitalization(.none)
                }
                
                Button(action: {
                    isPasswordVisible.toggle() // Alternar la visibilidad de la contraseña
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(isDarkMode ? .white : .gray)
                }
            }
            .padding(.vertical, 8)
            
            // Línea subrayada
            Rectangle()
                .frame(height: 1)
                .foregroundColor(isDarkMode ? .white : .gray)
        }
    }
}


struct CustomTituloHstack: View {
    let labelKey: String
    let isDarkMode: Int
    let aplicarTema: Bool
    var body: some View {
        HStack {
            Text(TextoIdiomaController.localizedString(forKey: labelKey))
                .foregroundColor(aplicarTema ? (isDarkMode == 1 ? .white : .black) : .black)
                .bold()
            Spacer()
        }
        .padding(.top, 20)
    }
}


struct FechaNacimientoPicker: View {
    @Binding var fechaNacimiento: Date?
    @State private var isDatePickerPresented: Bool = false
    @State private var fechaFormateada: String = "" // Variable para guardar la fecha formateada
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0
    
    var body: some View {
        VStack {
        
            // Texto que muestra la fecha seleccionada o el texto de "Seleccionar fecha"
            Button(action: {
                isDatePickerPresented = true
            }) {
                HStack {
                    if fechaNacimiento != nil {
                        Text(fechaFormateada)
                            .foregroundColor(.black)
                    } else {
                        Text(TextoIdiomaController.localizedString(forKey: "key-seleccionar-fecha"))
                            .foregroundColor(.gray) // Texto en gris para indicar selección pendiente
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            .sheet(isPresented: $isDatePickerPresented) {
                VStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { fechaNacimiento ?? Date() },
                            set: { newDate in
                                fechaNacimiento = newDate
                                fechaFormateada = idiomaApp == 1 ? formatDateToDMY(newDate) : formatDateToMDY(newDate)
                            }
                        ),
                        in: ...Calendar.current.date(from: DateComponents(year: 2024))!,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle()) // Estilo de rueda tipo spinner
                    .environment(\.locale, idiomaApp == 1 ? Locale(identifier: "es") : Locale(identifier: "en"))
                    .labelsHidden() // Oculta etiquetas adicionales
                    .padding()
                    
                    // Botón de confirmar selección de fecha
                    Button(TextoIdiomaController.localizedString(forKey: "key-confirmar")) {
                        isDatePickerPresented = false
                    }
                    .padding()
                    .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
    
    
    // Formateador de fecha Ingles
    private func formatDateToMDY(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    // Formateador de fecha Español
    private func formatDateToDMY(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}



struct FechaNacimientoPickerPerfil: View {
    @Binding var fechaNacimiento: Date?
    @State private var isDatePickerPresented: Bool = false
    @State private var fechaFormateada: String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0

    // Define la fecha predeterminada y el rango del DatePicker
    private var defaultDate: Date {
        fechaNacimiento ?? Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    }
    
    // Definir el rango para que incluya la fecha predeterminada como centro
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -100, to: defaultDate) ?? defaultDate
        let maxDate = calendar.date(byAdding: .year, value: 100, to: defaultDate) ?? defaultDate
        return minDate...maxDate
    }

    var body: some View {
        VStack {
            Button(action: {
                isDatePickerPresented = true
            }) {
                HStack {
                    if let fecha = fechaNacimiento {
                        Text(fechaFormateada.isEmpty ? formatFecha(fecha) : fechaFormateada)
                            .foregroundColor(.black)
                    } else {
                        Text(TextoIdiomaController.localizedString(forKey: "key-seleccionar-fecha"))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            .sheet(isPresented: $isDatePickerPresented) {
                VStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { fechaNacimiento ?? defaultDate },
                            set: { newDate in
                                fechaNacimiento = newDate
                                fechaFormateada = idiomaApp == 1 ? formatDateToDMY(newDate) : formatDateToMDY(newDate)
                            }
                        ),
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .environment(\.locale, idiomaApp == 1 ? Locale(identifier: "es") : Locale(identifier: "en"))
                    .labelsHidden()
                    .padding()

                    Button(TextoIdiomaController.localizedString(forKey: "key-confirmar")) {
                        isDatePickerPresented = false
                    }
                    .padding()
                    .foregroundColor(.black)
                }
            }
        }
        .padding()
        .onAppear {
            // Actualizar la fecha formateada si ya hay una fecha asignada
            if let fecha = fechaNacimiento {
                fechaFormateada = idiomaApp == 1 ? formatDateToDMY(fecha) : formatDateToMDY(fecha)
            }
        }
    }

    private func formatFecha(_ fecha: Date) -> String {
        return idiomaApp == 1 ? formatDateToDMY(fecha) : formatDateToMDY(fecha)
    }
    
    // Formateador de fecha Ingles
    private func formatDateToMDY(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    // Formateador de fecha Español
    private func formatDateToDMY(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}










enum Genero: String, CaseIterable, Identifiable {
    case ninguno = "key-seleccionar-opcion"
    case masculino = "key-masculino"
    case femenino = "key-femenino"
    
    var id: String { self.rawValue }
    
    // Método para obtener el texto localizado
    var localized: String {
        return TextoIdiomaController.localizedString(forKey: self.rawValue)
    }
}

struct ImagePickerOption: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let imageName: String
}


enum Paises: String, CaseIterable, Identifiable {
    case ninguno = "key-seleccionar-opcion"
    case elsalvador = "key-el-salvador"
    case guatemala = "key-guatemala"
    case honduras = "key-honduras"
    case nicaragua = "key-nicaragua"
    case mexico = "key-mexico"
    case otros = "key-otros"
    
    var id: String { rawValue }
    
    var image: String {
        switch self {
        case .ninguno:
            return ""
        case .elsalvador:
            return "flag_elsalvador"
        case .guatemala:
            return "flag_guatemala"
        case .honduras:
            return "flag_honduras"
        case .nicaragua:
            return "flag_nicaragua"
        case .mexico:
            return "flag_mexico"
        case .otros:
            return "localizacion"
        }
    }
    
    // Método para obtener el texto localizado
    var localized: String {
        return TextoIdiomaController.localizedString(forKey: self.rawValue)
    }
    
    // Nueva propiedad computada para obtener el número asociado
    var number: Int {
        switch self {
        case .ninguno: return 0
        case .elsalvador: return 1
        case .guatemala: return 2
        case .honduras: return 3
        case .nicaragua: return 4
        case .mexico: return 5
        case .otros: return 6
        }
    }
    
    // Lista de departamentos por país
    var departments: [Department] {
        switch self {
        case .elsalvador:
            return [Department(id: 1, name: "Santa Ana"), 
                    Department(id: 2,name: "Chalatenango"),
                    Department(id: 3, name: "Sonsonate"),
                    Department(id: 4, name: "La Libertad"),
                    Department(id: 5, name: "Ahuachapán")
            ]
                        
        case .guatemala:
            return [Department(id: 6,name: "San Marcos"),
                    Department(id: 7,name: "Quetzaltenango"),
                    Department(id: 8,name: "Suchitepéquez"),
                    Department(id: 9,name: "Retalhuleu"),
                    Department(id: 10,name: "Solola"),
                    Department(id: 11,name: "Sacatepequez"),
                    Department(id: 12,name: "Chimaltenango"),
                    Department(id: 13,name: "Guatemala"),
                    Department(id: 14,name: "Escuintla"),
                    Department(id: 15,name: "Santa Rosa"),
                    Department(id: 16,name: "Jalapa"),
                    Department(id: 17,name: "Jutiapa"),
                    Department(id: 18,name: "Chiquimula"),
                    Department(id: 19,name: "Zacapa")]
            
        case .honduras:
            return [Department(id: 20,name: "Francisco Morazán"),
                    Department(id: 21,name: "Olancho"),
                    Department(id: 22,name: "El Paraíso")]
        case .nicaragua:
            return [Department(id: 23,name: "Estelí"),
                    Department(id: 24,name: "Madriz"),
                    Department(id: 25,name: "Nueva Segovia")]

        case .mexico:
            return [Department(id: 26,name: "Hidalgo"),
                    Department(id: 27,name: "Chiapas")]
        case .ninguno:
            return []
        case .otros:
            return []
        }
    }
}


struct Department: Identifiable {
    let id: Int
    let name: String
}


enum ToastColor {
    case azul
    case verde
    case gris
    case rojo
    
    var color: Color {
        switch self {
        case .azul:
            return Color("cazulv1")
        case .verde:
            return Color("cverdev1")
        case .gris:
            return Color("cgrisv1")
        case .rojo:
            return Color("crojov1")
        }
    }
}



struct MunicipioResult {
    let success: Int
    let listado: [Municipio]
}

struct Municipio: Identifiable {
    let id: Int
    let nombre: String
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

// CAMBIAR COLOR AL TOOLBAR Y AL TITLE
struct CustomNavigationBarModifier: UIViewControllerRepresentable {
    let backgroundColor: UIColor
    let titleColor: UIColor

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor // Cambia el color de fondo aquí
        appearance.titleTextAttributes = [.foregroundColor: titleColor] // Cambia el color del título
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


struct LineaHorizontal: View {
    let altura: Float
    let espaciado: Int
    let temaApp: Int
        
    var body: some View {
        VStack {
            Rectangle()
              .frame(height: CGFloat(altura)) // Espesor de la línea
              .foregroundColor(temaApp == 1 ? .white : .black) // Cambia el color aquí
              .padding(.leading, CGFloat(espaciado))
        }
    }
}


enum EnumTipoVistaTabsDevocional: Identifiable {
    case informacion
 
    var id: Self { self }
}

enum EnumTipoVistaAjustes: Identifiable {
    case perfil
    case notificaciones
    case contrasena
    case insignias
    case cerrarsesion
 
    var id: Self { self }
}



struct CambiarIdiomaModal: View {
    @Binding var idiomaSeleccionado: Int
    let cambiarIdioma: (Int) -> Void
    
    // Claves de los idiomas a traducir
    let idiomas = [
          (texto: TextoIdiomaController.localizedString(forKey: "key-espanol"), valor: 1),
          (texto: TextoIdiomaController.localizedString(forKey: "key-ingles"), valor: 2)
      ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(TextoIdiomaController.localizedString(forKey: "key-seleccionar-idioma"))
                .font(.headline)
                .padding(.top)

            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Picker(TextoIdiomaController.localizedString(forKey: "key-idioma"), selection: $idiomaSeleccionado) {
                ForEach(idiomas, id: \.valor) { idioma in
                    Text(idioma.texto).tag(idioma.valor)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: idiomaSeleccionado) { nuevoIdioma in
                cambiarIdioma(nuevoIdioma)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .fraction(0.4)])
    }
}

enum EnumTipoVistaSplash: Identifiable {
    case login
    case principal
    
    var id: Self { self }
}
