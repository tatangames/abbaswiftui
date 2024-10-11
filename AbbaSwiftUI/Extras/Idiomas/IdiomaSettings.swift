//
//  IdiomaSettings.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 10/10/24.
//

import SwiftUI
import Combine

// PARA CAMBIO DE IDIOMA INSTANTANEO
class IdiomaSettings: ObservableObject {
    @Published var idioma: Int {
        didSet {
            UserDefaults.standard.set(idioma, forKey: DatosGuardadosKeys.idiomaApp)
            NotificationCenter.default.post(name: Notification.Name("IdiomaChanged"), object: nil)
        }
    }
    init() {
        self.idioma = UserDefaults.standard.integer(forKey: DatosGuardadosKeys.idiomaApp)
    }
}
