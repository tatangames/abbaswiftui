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
    @State private var openLoadingSpinner: Bool = true
    @State private var boolMostrarVista: Bool = false
    @State private var boolHayImagen: Bool = false
    @StateObject var viewModel = PerfilViewModel()
    
    @State private var boolHayDatos: Bool = true
    @State private var imgGenero: String = "generom" // defecto
    
    @State private var urlImagenUsuario: String = ""
    
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
                        }


                     
                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // para expansion
                } // end-scrollview

             
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
    
    
    private func loadData() {
        openLoadingSpinner = true
        viewModel.infoPerfilRX(idToken: idToken, idCliente: idCliente) { result in
            switch result {
            case .success(let json):
                let success = json["success"].int ?? 0
                switch success {
                case 1:
                    
                    print("ENTRAAAA")
                    
                   let _nombre = json["nombre"].string ?? ""
                   let _apellido = json["apellido"].string ?? ""
                   let _fechaNac = json["fecha_nacimiento"].string ?? ""
                   let _hayimagen = json["hayimagen"].int ?? 0
                   let _imagen = json["imagen"].string ?? ""
                   let _genero = json["genero"].int ?? 0 // 1: masculino 2: femenino
                    
                   if(_hayimagen == 1){
                       urlImagenUsuario = _imagen
                       boolHayImagen = true
                   }
                    
                    print("url: \(_imagen)")
                    
                   
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

