//
//  TextoIdiomaController.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import Foundation

class TextoIdiomaController {
    static func localizedString(forKey key: String) -> String {
        let language = UserDefaults.standard.integer(forKey: DatosGuardadosKeys.idiomaApp)
        let languageCode = language == 2 ? "en" : "es"
        
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return ""
        }
        
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
