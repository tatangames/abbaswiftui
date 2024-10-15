//
//  ModeloMisPlanes.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 14/10/24.
//

import Foundation

struct ModeloMisPlanes: Codable {
    let success: Int
    let hayinfo: Int
    let listado: [ModeloMisPlanesListado]  // Changed to an array
}

struct ModeloMisPlanesListado: Codable, Identifiable {
    let idPlanes: Int
    let titulo: String
    let subtitulo: String
    let imagen: String
    let imagenPortada: String
    
    // Propiedad `id` para Identifiable
    let id: UUID = UUID()  // Genera un identificador único automáticamente
    
    enum CodingKeys: String, CodingKey {
        case idPlanes = "idplan"
        case titulo
        case subtitulo
        case imagen
        case imagenPortada      
    }
}
