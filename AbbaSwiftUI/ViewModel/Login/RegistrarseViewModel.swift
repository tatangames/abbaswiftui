//
//  RegistrarseViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 5/10/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class RegistrarseViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func registrarseRX(nombre: String, apellido: String, fecha: String, genero: Int, municipio: Int,
                       correo: String, contrasena: String, idonesignal: String,
                       paisotros: String, ciudadotros: String) -> Observable<Result<JSON, Error>> {
        
        // Si ya hay una solicitud en progreso, retorna un Observable vacío
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
        }
        
        isRequestInProgress = true
        
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiRegistroUsuario
            let parameters: [String: Any] = [
                "nombre": nombre,
                "apellido": apellido,
                "edad": fecha,
                "genero": genero,
                "iglesia": municipio,
                "correo": correo,
                "password": contrasena,
                "version": apiVersionApp,
                "idonesignal" : idonesignal,
                "paisotros": paisotros,
                "ciudadotros": ciudadotros
            ]
            
            let request = AF.request(encodeURL, method: .post, parameters: parameters)
                .responseData { response in
                    self.loadingSpinner = false
                    self.isRequestInProgress = false
                    
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        observer.onNext(.success(json))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onNext(.failure(error))
                        observer.onCompleted()
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .retry()        
    }
}
