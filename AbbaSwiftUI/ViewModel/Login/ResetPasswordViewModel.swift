//
//  ResetPasswordViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 6/10/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

// aqui enviamos el codigo e inicia sesion

class ResetPasswordViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    let disposeBag = DisposeBag()
    
    func resetPasswordRX(password: String, token: String) -> Observable<Result<JSON, Error>> {
        
        // Si ya hay una solicitud en progreso, retorna un Observable vacío
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
        }
        
        isRequestInProgress = true
        
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiResetPassword
            let parameters: [String: Any] = [
                "password": password,
            ]
            
            // Definir los headers con el token
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            
            let request = AF.request(encodeURL, method: .post, parameters: parameters, headers: headers)
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
    }
}
