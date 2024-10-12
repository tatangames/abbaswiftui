//
//  ListaNotificacionesViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 11/10/24.
//
import SwiftUI
import SwiftyJSON
import Alamofire
import RxSwift
import AlertToast
import Combine
import Foundation

// PARA LISTA DE NOTIFICACIONES DE PAGINACION

class ListaNotificacionesViewModel: ObservableObject {
    
    @Published var loadingSpinner: Bool = false
    @Published var isRequestInProgress: Bool = false
    @Published var notifications: [NotificationesPager] = []
    @Published var hasMorePages: Bool = true
    var currentPage: Int = 1
        
    let disposeBag = DisposeBag()
    private let itemsPerPage = 10
    
    func fetchNotifications(idCliente: String, idToken: String, idioma: Int) -> Observable<Result<ModeloNotificationResponse, Error>> {
        guard !isRequestInProgress else {
            return Observable.just(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress."])))
        }
        
        isRequestInProgress = true
        loadingSpinner = true
        
        let requestURL = apiListadoNotificaciones
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)"
        ]
        
        let parameters: [String: Any] = [
            "iduser": idCliente,
            "idiomaplan": idioma,
            "page": currentPage,
            "limit": itemsPerPage
        ]
        
        return Observable<Result<ModeloNotificationResponse, Error>>.create { observer in
            let request =
            AF.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseDecodable(of: ModeloNotificationResponse.self) { response in
                    self.loadingSpinner = false
                    self.isRequestInProgress = false
                    self.loadingSpinner = false
                    
                    switch response.result {
                    case .success(let notificationResponse):
                        // Verificar si hay datos
                        if !notificationResponse.listado.data.isEmpty {
                            // Solo agregar notificaciones si hay datos
                            self.notifications.append(contentsOf: notificationResponse.listado.data)
                            
                            // Incrementar currentPage solo si se recibieron datos
                            self.currentPage += 1
                            
                            // Verificar si hay más páginas
                            self.hasMorePages = notificationResponse.listado.currentPage < notificationResponse.listado.lastPage
                        } else {
                            // Si no hay más datos, no se incrementa currentPage
                            self.hasMorePages = false
                            print("No hay más notificaciones para cargar.")
                        }
                        
                        observer.onNext(.success(notificationResponse))
                    case .failure(let error):
                        observer.onNext(.failure(error))
                    }
                    
                    self.isRequestInProgress = false // Restablecer después de la solicitud
                    observer.onCompleted()
                }
            
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
