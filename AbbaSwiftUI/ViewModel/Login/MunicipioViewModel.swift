//
//  MunicipioViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 4/10/24.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class MunicipioViewModel: ObservableObject {
    @Published var loadingSpinner: Bool = false
    let disposeBag = DisposeBag()
    
    func listadoMunicipiosRX(idDepa: Int) -> Observable<Result<JSON, Error>> {
           
        return Observable<Result<JSON, Error>>.create { observer in
            self.loadingSpinner = true
            let encodeURL = apiListadoMunicipios
            let parameters: [String: Any] = ["iddepa": idDepa]
            
            let request = AF.request(encodeURL, method: .post, parameters: parameters)
                .responseData { response in
                    self.loadingSpinner = false
                    
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
        .retry(3) // Reintenta hasta 3 veces en caso de error
     
    }
}
