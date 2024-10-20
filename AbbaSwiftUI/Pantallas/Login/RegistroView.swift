//
//  RegistroView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation
import OneSignalFramework

struct RegistroView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp:Int = 0
    @State private var selectedOption:Int = 0
    @State private var showToastBool:Bool = false
    @State private var openLoadingSpinner: Bool = false
    @State private var popVerificar:Bool = false
    @State private var popMensaje:Bool = false
    @State private var popMensajeString:String = ""
    @State private var boolPantallaPrincipal: Bool = false
    @State private var generoSeleccionado: Genero = .ninguno
    @State private var vistaPais:Bool = true
    @State private var nombre:String = ""
    @State private var apellido:String = ""
    @State private var fechaNacimientoDate: Date? = nil
    @State private var correoElectronico:String = ""
    @State private var password:String = ""
    @State private var nombrePais:String = ""
    @State private var nombreCiudad:String = ""
    @State private var selectedPaises: Paises = .ninguno
    @State private var selectedDepartment: Department?
    @State private var selectedMunicipio: Municipio?
    @State private var municipios: [Municipio] = []
    @StateObject private var toastViewModel = ToastViewModel()
    
    let viewModel = MunicipioViewModel()
    let viewModelRegistrarse = RegistrarseViewModel()
    
    // IDENTIFICADOR ONE SIGNAL
    let idonesignal: String = OneSignal.User.pushSubscription.id ?? ""
        
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack(spacing: 15) {
                    
                    //***************************
                    
                    // Alinea el texto a la izquierda
                    HStack {
                        CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-primer-nombre"), isDarkMode: temaApp, aplicarTema: true)
                    }
                    
                    VStack {
                        CustomTextField(labelKey: "key-nombre", isDarkMode: temaApp == 1 ? true : false, text: $nombre, maxLength: 50, keyboardType: .default)
                    }
                    
                    //***************************
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-apellido"), isDarkMode: temaApp, aplicarTema: true)
                    
                    VStack {
                        CustomTextField(labelKey: "key-apellido", isDarkMode: temaApp != 0, text: $apellido, maxLength: 50, keyboardType: .default)
                    }
                    
                    //***************************
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-fecha-nacimiento"), isDarkMode: temaApp, aplicarTema: true)
                    FechaNacimientoPicker(fechaNacimiento: $fechaNacimientoDate)
                    
                    //***************************
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-seleccionar-genero"), isDarkMode: temaApp, aplicarTema: true)
                    
                    Menu {
                        ForEach(Genero.allCases, id: \.self) { genero in
                            Button(action: {
                                generoSeleccionado = genero
                            }) {
                                Text(genero.localized)
                                    .foregroundColor(.black) // Cambia el color del texto del menú a negro
                            }
                        }
                    } label: {
                        HStack {
                            Text(generoSeleccionado.localized)
                                .foregroundColor(.black) // Cambia el color del texto del label a negro
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black) // Cambia el color del ícono a negro
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(temaApp==1 ? Color.white : Color.gray.opacity(0.1)) // Fondo blanco para el contenedor del menú
                        .cornerRadius(8)
                    }
                    .accentColor(.black)
                    
                    //*************   PAISES    **************
                    
                    VStack {
                        
                        CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-seleccionar-pais"), isDarkMode: temaApp, aplicarTema: false)
                        
                        Menu {
                            ForEach(Paises.allCases) { country in
                                Button(action: {
                                    selectedPaises = country
                                    selectedDepartment = nil // Limpiar la selección de departamentos
                                    selectedMunicipio = nil
                                    municipios = []
                                    vistaPais = (selectedPaises != .otros)
                                }) {
                                    HStack {
                                        if !country.image.isEmpty {
                                            Image(country.image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 20)
                                        }
                                        Text(country.localized)
                                            .foregroundColor(Color.black)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if !selectedPaises.image.isEmpty {
                                    Image(selectedPaises.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 20)
                                }
                                Text(selectedPaises.localized)
                                    .foregroundColor(Color.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // VISTA
                        if(vistaPais){
                            
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-departamento"), isDarkMode: temaApp, aplicarTema: false)
                            
                            // Segundo menú: Selección de Departamento según el país
                            Menu {
                                ForEach(selectedPaises.departments) { department in
                                    Button(action: {
                                        selectedDepartment = department
                                        selectedMunicipio = nil // Limpiar selección de municipio al cambiar de departamento
                                        municipios = [] // Limpiar la lista de municipios al cambiar de departamento
                                        fetchMunicipios(idDepa: department.id)
                                    }) {
                                        Text(department.name)
                                            .foregroundStyle(Color.black)
                                    }
                                }
                            } label: {
                                HStack {
                                    // Mostrar el nombre del departamento seleccionado o un texto vacío si no hay selección
                                    Text(selectedDepartment?.name ?? TextoIdiomaController.localizedString(forKey: "key-seleccionar-opcion"))
                                        .foregroundColor(municipios.isEmpty ? Color.gray : Color.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .disabled(selectedPaises == .ninguno)
                            
                            
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-municipio"), isDarkMode: temaApp, aplicarTema: false)
                            
                            Menu {
                                ForEach(municipios) { municipio in
                                    Button(action: {
                                        selectedMunicipio = municipio
                                    }) {
                                        Text(municipio.nombre) // Cambiado de `municipio.name` a `municipio.nombre`
                                            .foregroundStyle(Color.black)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedMunicipio?.nombre ?? TextoIdiomaController.localizedString(forKey: "key-seleccionar-opcion"))
                                        .foregroundColor(municipios.isEmpty ? Color.gray : Color.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .disabled(selectedDepartment == nil || municipios.isEmpty)
                            
                        }else{
                            // cuando seleccionas .ninguno
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-pais"), isDarkMode: temaApp, aplicarTema: false)
                            
                            CustomTextField(labelKey: "key-pais", isDarkMode: temaApp != 0, text: $nombrePais, maxLength: 100, keyboardType: .default)
                            
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-ciudad"), isDarkMode: temaApp, aplicarTema: false)
                            
                            CustomTextField(labelKey: "key-ciudad", isDarkMode: temaApp != 0, text: $nombreCiudad, maxLength: 100, keyboardType: .default)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-correo-electronico"), isDarkMode: temaApp, aplicarTema: true)
                    
                    CustomTextField(labelKey: "key-correo-electronico", isDarkMode: temaApp != 0, text: $correoElectronico, maxLength: 100, keyboardType: .emailAddress)
                    
                    
                    CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-contrasena"), isDarkMode: temaApp, aplicarTema: true)
                    
                    CustomPasswordField(
                        labelKey: "key-contrasena",  // Placeholder personalizado
                        isDarkMode: temaApp == 1 ? true : false,                   // Modo claro u oscuro
                        password: $password,                 // Variable que contiene la contraseña
                        maxLength: 20                        // Longitud máxima de la contraseña
                    )
                    
                    
                    
                    
                    //****************  BOTON REGISTRARSE   *********************************
                    
                    Button(action: {
                        verificarCampos()
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-registrarse"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("cazulv1"))
                            .cornerRadius(8)
                    }
                    .padding(.top, 50)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    Spacer()
                }
                .padding()
                .navigationTitle(TextoIdiomaController.localizedString(forKey: "key-registro"))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                                
                                Text(TextoIdiomaController.localizedString(forKey: "key-atras"))
                                    .foregroundColor(temaApp == 1 ? .white : .black)
                            }
                        }
                    }
                }
            }
            .background(CustomNavigationBarModifier(backgroundColor: temaApp == 1 ? .black : .white,
                                                    titleColor: temaApp == 1 ? .white : .black))
            
            .onTapGesture {
                hideKeyboard()
            }
            
            if popVerificar {
                PopImg2BtnView(isActive: $popVerificar, imagen: .constant("infocolor"), descripcion: .constant(TextoIdiomaController.localizedString(forKey: "key-completar-registro")),
                               txtCancelar: .constant(TextoIdiomaController.localizedString(forKey: "key-editar")),
                               txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-registrarse")),
                               cancelAction: {}, acceptAction: {
                    popVerificar = false
                    apiServerRegistrarse()
                }).zIndex(1)
            }
            
            if popMensaje {
                PopImg1BtnView(isActive: $popMensaje, imagen: .constant("infocolor"), bLlevaTitulo: .constant(false), titulo: .constant(""), descripcion: .constant(popMensajeString), txtAceptar: .constant(TextoIdiomaController.localizedString(forKey: "key-aceptar")), acceptAction: {})
                    .zIndex(1)
            }
            
            if openLoadingSpinner {
                LoadingSpinnerView()
                    .transition(.opacity) // Transición de opacidad
                    .zIndex(10)
            }
        }
        .background(temaApp == 1 ? Color.black : Color.white)
        .toast(isPresenting: $toastViewModel.showToastBool, alert: {
            toastViewModel.customToast
        })
        .onReceive(viewModel.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .onReceive(viewModelRegistrarse.$loadingSpinner) { loading in
            openLoadingSpinner = loading
        }
        .navigationDestination(isPresented: $boolPantallaPrincipal) {
            PrincipalView()
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
        }
        
    }
    
    private func verificarCampos(){
        
        hideKeyboard()
        
        if(nombre.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-nombre-requerido"), tipoColor: .gris)
            return
        }
        
        if(apellido.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-apellido-requerido"), tipoColor: .gris)
            return
        }
        
        if(fechaNacimientoDate == nil){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-fecha-nacimiento-es-requerido"), tipoColor: .gris)
            return
        }
        
        if(generoSeleccionado == .ninguno){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-genero-es-requerido"), tipoColor: .gris)
            return
        }
        
        
        if(vistaPais){
            
            if(selectedMunicipio == nil){
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-seleccionar-municipio"), tipoColor: .gris)
                return
            }
            
        }else{
            if(nombrePais.isEmpty){
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-pais-es-requerido"), tipoColor: .gris)
                return
            }
            
            if(nombreCiudad.isEmpty){
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-ciudad-es-requerido"), tipoColor: .gris)
                return
            }
        }
        
        
        if(correoElectronico.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-requerido"), tipoColor: .gris)
            return
        }
        
        if !isValidEmail(correoElectronico) {
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-no-valido"), tipoColor: .gris)
            return
        }
        
        if(password.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-password-requerido"), tipoColor: .gris)
            return
        }
        
        if(password.count < 5){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-contrasena-minimo-cinco"), tipoColor: .gris)
            return
        }
        
        popVerificar = true
    }
    
    private func apiServerRegistrarse(){
        let _fechaFormat = formatDateToMDY(fechaNacimientoDate ?? Date())
        let _genero = generoSeleccionado == .masculino ? 1 : 2
        let _municipio = selectedMunicipio?.id ?? 0
        
        viewModelRegistrarse.registrarseRX(nombre: nombre, apellido: apellido, fecha: _fechaFormat, genero: _genero, municipio: _municipio, correo: correoElectronico, contrasena: password, idonesignal: idonesignal, paisotros: nombrePais, ciudadotros: nombreCiudad)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    
                    switch success {
                    case 1:
                        // correo ya registrado
                        popMensajeString = TextoIdiomaController.localizedString(forKey: "key-correo-ya-registrado")
                        popMensaje = true
                    case 2:
                        // usuario registrado
                        let _id = json["id"].int ?? 0
                        let _token = json["token"].string ?? ""
                        
                        idCliente = String(_id)
                        idToken = _token
                        boolPantallaPrincipal = true
                    default:
                        // error
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                    }
                    
                case .failure(_):
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                }
            }, onError: { error in
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
            })
            .disposed(by: viewModelRegistrarse.disposeBag)
    }
    
    private func fetchMunicipios(idDepa: Int) {
        viewModel.listadoMunicipiosRX(idDepa: idDepa)
            .subscribe(onNext: { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    
                    switch success {
                    case 1:
                        let municipiosJSON = json["listado"].arrayValue
                        self.municipios = municipiosJSON.map { item in
                            Municipio(
                                id: item["id"].intValue,
                                nombre: item["nombre"].stringValue
                            )
                        }
                    default:
                        // error
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
                }
            }, onError: { error in
                print("Error en la suscripción: \(error)")
                toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-error-intentar-de-nuevo"), tipoColor: .rojo)
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func formatDateToMDY(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
 
}

#Preview {
    RegistroView()
}
