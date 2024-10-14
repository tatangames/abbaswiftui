//
//  CodigoOTPView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 6/10/24.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation
import SDWebImageSwiftUI
import PhotosUI

struct PerfilView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject var viewModel = PerfilViewModel()
    @StateObject var viewModelActualizar = PerfilActualizarViewModel()
    @State private var openLoadingSpinner: Bool = true
    @State private var boolMostrarVista: Bool = false
    @State private var boolHayImagen: Bool = false
    @State private var boolHayDatos: Bool = true
    @State private var imgGenero: String = "generom" // defecto
    @State private var urlImagenUsuario: String = ""
    @State private var nombre:String = ""
    @State private var apellido:String = ""
    @State private var fechaNacimientoDate: Date? = nil
    @State private var correoElectronico:String = ""
    @State private var fechaNacUsuario:String = ""
    
    // Camara
    @State private var isCameraPresented:Bool = false
    @State private var sheetCamaraGaleria:Bool = false
    @State private var selectedImage:UIImage?
    @State private var selectedItem:PhotosPickerItem? = nil
    @State private var isPickerPresented:Bool = false
    @State private var actualizaraImagen:Bool = false
    @State private var showSettingsAlert:Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        if boolMostrarVista {
                            if boolHayImagen {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            sheetCamaraGaleria.toggle()
                                        }
                                        .padding(.top, 10)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    WebImage(url: URL(string: baseUrlImagen + urlImagenUsuario))
                                        .resizable()
                                        .indicator(.activity)
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            sheetCamaraGaleria.toggle()
                                        }
                                        .padding(.top, 10)
                                        .frame(maxWidth: .infinity)
                                }
                                
                            } else {
                                Image(uiImage: selectedImage ?? UIImage(named: imgGenero)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .onTapGesture {
                                        sheetCamaraGaleria.toggle()
                                    }
                                    .padding(.top, 10)
                                    .frame(maxWidth: .infinity)
                            }
                            
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
                            
                            
                            
                            FechaNacimientoPickerPerfil(fechaNacimiento: $fechaNacimientoDate)
                                .onAppear {
                                    if let date = convertStringToDate(fechaNacUsuario) {
                                        fechaNacimientoDate = date
                                    }
                                }
                            
                            
                            
                            CustomTituloHstack(labelKey: TextoIdiomaController.localizedString(forKey: "key-correo-electronico"), isDarkMode: temaApp, aplicarTema: true)
                            
                            CustomTextField(labelKey: "key-correo-electronico", isDarkMode: temaApp != 0, text: $correoElectronico, maxLength: 100, keyboardType: .emailAddress)
                            
                            
                            //****************  BOTON ACTUALIZAR   *********************************
                            
                            Button(action: {
                                verificarCampos()
                            }) {
                                Text(TextoIdiomaController.localizedString(forKey: "key-actualizar"))
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
                            
                        } //end-if
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // para expansion
                } // end-scrollview
                                
                if openLoadingSpinner {
                    LoadingSpinnerView()
                        .transition(.opacity) // Transición de opacidad
                        .zIndex(10)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // para expansion
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .photosPicker(isPresented: $isPickerPresented, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                if let newItem = newItem {
                    newItem.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let image = UIImage(data: data) {
                                selectedImage = image
                                actualizaraImagen = true
                            }
                        case .failure(let error):
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .sheet(isPresented: $sheetCamaraGaleria) {
                BottomSheetCamaraGaleriaView(onOptionSelected: { option in
                    
                    if option == 1{
                        checkPhotoLibraryPermission()
                    }else{
                        checkCameraPermission()
                    }
                    
                    sheetCamaraGaleria = false // Cierra el bottom sheet
                })
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                    .onChange(of: selectedImage) { newImage in
                        if newImage != nil {
                            actualizaraImagen = true
                        }
                    }
            }
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
                    Text(TextoIdiomaController.localizedString(forKey: "key-perfil"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .background(temaApp == 1 ? Color.black : Color.white)
            .onReceive(viewModel.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .onReceive(viewModelActualizar.$loadingSpinner) { loading in
                openLoadingSpinner = loading
            }
            .onAppear {
                loadData()
            }
            .alert(isPresented: $showSettingsAlert) {
                Alert(
                    title: Text(TextoIdiomaController.localizedString(forKey: "key-acceso-galeria-camara")),
                    message: Text(TextoIdiomaController.localizedString(forKey: "key-porfavor-habilitar-permiso-camara")),
                    primaryButton: .default(Text(TextoIdiomaController.localizedString(forKey: "key-ajustes"))) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .default(Text(TextoIdiomaController.localizedString(forKey: "key-cancelar"))) {
                    }
                )
            }
            .toast(isPresenting: $toastViewModel.showToastBool, alert: {
                toastViewModel.customToast
            })
        } // end-navigationView
        .background(CustomNavigationBarModifier(backgroundColor: .white, titleColor: .black))
    }
    
    
    private func verificarCampos(){
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
        
        if(correoElectronico.isEmpty){
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-requerido"), tipoColor: .gris)
            return
        }
        
        if !isValidEmail(correoElectronico) {
            toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-no-valido"), tipoColor: .gris)
            return
        }
        
        actualizarPerfil()
    }
    
    private func actualizarPerfil(){
        
        // Ejemplo de uso
        if let _fechaFormat = convertToMySQLDateFormat(fechaNacUsuario) {
            
            viewModelActualizar.actualizarPerfilRX(idToken: idToken, idCliente: idCliente, nombre: nombre, apellido: apellido, fechanac: _fechaFormat, correo: correoElectronico, selectedImage: selectedImage) { result in
                switch result {
                case .success(let json):
                    let success = json["success"].int ?? 0
                    switch success {
                    case 1:
                        // correo ya registrado
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-correo-ya-registrado"), tipoColor: .gris)
                    case 2:
                        // actualizado
                        toastViewModel.showCustomToast(with: TextoIdiomaController.localizedString(forKey: "key-actualizado"), tipoColor: .verde)
                        
                    default:
                        mensajeError()
                    }
                    
                case .failure(_):
                    mensajeError()
                }
            }
        }
    }
    
    // UTILIZADO EN EL PICKER
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Formato inicial de la cadena
        return dateFormatter.date(from: dateString)
    }

    // UTILIZADO AL ENVIAR AL SERVER
    func convertToMySQLDateFormat(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Ajusta esto según el formato inicial de la fecha que recibas
        
        // Convertir el string a Date
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd" // Formato esperado por MySQL
            return dateFormatter.string(from: date)
        }
        
        return nil // Retorna nil si la conversión falla
    }
    
    private func loadData() {
        openLoadingSpinner = true
        viewModel.infoPerfilRX(idToken: idToken, idCliente: idCliente) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    let _nombre = json["nombre"].string ?? ""
                    let _apellido = json["apellido"].string ?? ""
                    let _fecha = json["fecha_nacimiento"].string ?? ""
                    let _hayimagen = json["hayimagen"].int ?? 0
                    let _imagen = json["imagen"].string ?? ""
                    let _correo = json["correo"].string ?? ""
                    let _genero = json["genero"].int ?? 0 // 1: masculino 2: femenino
                    
                    if(_hayimagen == 1){
                        urlImagenUsuario = _imagen
                        boolHayImagen = true
                    }
                    
                    nombre = _nombre
                    apellido = _apellido
                    fechaNacUsuario = _fecha
                    correoElectronico = _correo
                    
                    if(_genero == 2){
                        imgGenero = "generof"
                    }
                    
                    boolMostrarVista = true
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
    
    
    // verificar permiso para galeria
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //print("Permiso autorizado")
            isPickerPresented = true
        case .denied, .restricted:
            //print("Permiso denegado o restrictivo")
            showSettingsAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    //print("Acceso autorizado despues del request")
                    isPickerPresented = true
                } else {
                    //print("Accesso denegado despues del request")
                    showSettingsAlert = true
                }
            }
        case .limited:
            showSettingsAlert = true
        @unknown default:
            // print("Estado desconocido")
            showSettingsAlert = true
        }
    }
    
    func checkCameraPermission() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                isCameraPresented = true
            case .denied, .restricted:
                showSettingsAlert = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        isCameraPresented = true
                    } else {
                        showSettingsAlert = true
                    }
                }
            @unknown default:
                showSettingsAlert = true
            }
        } else {
            print("Cámara no disponible")
        }
    }
    
}

