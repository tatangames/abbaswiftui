//
//  MeditacionViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 23/10/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class MeditacionViewModel: ObservableObject {
    @Published var jsonResponse: JSON?
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    @Published var error: Error?
    
    private let disposeBag = DisposeBag()
     
    func listadoPreguntasRX(idToken: String, idCliente: String, idBlockDeta: Int, idiomaApp: Int, completion: @escaping (Result<JSON, Error>) -> Void) {
        // Verificar si ya hay una solicitud en curso
        guard !isRequestInProgress else { return }
        
        // Indicar que la solicitud está en progreso
        isRequestInProgress = true
        loadingSpinner = true
        
        let encodeURL = apiListadoPreguntas
        let headers: HTTPHeaders = ["Authorization": "Bearer \(idToken)"]
        let parameters: [String: Any] = [
            "iduser": idCliente,
            "idblockdeta": idBlockDeta,
            "idiomaplan": idiomaApp
        ]
        
        Observable<JSON>.create { observer in
            let request = AF.request(encodeURL, method: .post, parameters: parameters, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        if let httpResponse = response.response, httpResponse.statusCode != 200 {
                            observer.onError(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error en el servidor con código: \(httpResponse.statusCode)"]))
                        } else {
                            observer.onNext(json)
                            observer.onCompleted()
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .retry(when: { errors in
            errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                print("Error: \(error). Reintentando...")
                return Observable.timer(.seconds(2), scheduler: MainScheduler.instance)
            }
        })
        .subscribe(
            onNext: { json in
                self.jsonResponse = json
                self.loadingSpinner = false
                self.isRequestInProgress = false // La solicitud ha finalizado
                completion(.success(json))
            },
            onError: { error in
                self.error = error
                self.loadingSpinner = false
                self.isRequestInProgress = false // La solicitud ha finalizado con error
                completion(.failure(error))
            }
        )
        .disposed(by: disposeBag)
    }
}
