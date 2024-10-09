//
//  TextoIdiomaController.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import Foundation
class TextoIdiomaController {
    
    static func localizedString(forKey key: String) -> String {
        var language = "es" // Valor por defecto
        
        // Obtener el idioma desde UserDefaults
        if let selectedLanguage = UserDefaults.standard.value(forKey: "IDIOMA") as? Int {
            switch selectedLanguage {
            case 1:
                language = "es" // Español
            case 2:
                language = "en" // Inglés
            default:
                language = "es" // Por defecto
            }
        }
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return ""
        }
        
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
