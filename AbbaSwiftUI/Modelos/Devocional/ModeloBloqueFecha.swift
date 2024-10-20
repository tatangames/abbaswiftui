//
//  ModeloBloqueFecha.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 19/10/24.
//

import Foundation

struct ResponseDataBloqueFecha: Codable {
    let portada: String
    let success: Int
    let listado: [ListadoBloqueFecha]
}

struct ListadoBloqueFecha: Codable {
    let textopersonalizado: String
    let detalle: [DetalleBloqueFecha]
    let id: Int
    let fecha_inicio: String
    let id_planes: Int
}

struct DetalleBloqueFecha: Codable {
    let id: Int
    let id_planes_bloques: Int
    let url_link: String
    let redireccionar_web: Int
    let completado: Int
    let posicion: Int
    let titulo: String
}



