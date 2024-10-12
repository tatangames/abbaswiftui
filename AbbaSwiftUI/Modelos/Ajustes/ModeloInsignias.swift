//
//  ModeloInsignias.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 12/10/24.
//

import Foundation

struct ModeloInsignias: Codable {
    let success: Int
    let hayinfo: Int
    let listado: [ModeloInsigniasListado]  // Changed to an array
}

struct ModeloInsigniasListado: Codable, Identifiable {
    let id: Int
    let imagen: String
    let titulo: String
    let descripcion: String
}
