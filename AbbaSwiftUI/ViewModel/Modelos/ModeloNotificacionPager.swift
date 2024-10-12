//
//  NotificacionPager.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 11/10/24.
//

import Foundation

// UTILIZADO LISTADO DE NOTIFICACIONES CON PAGINACION

struct ModeloNotificationResponse: Codable {
    let success: Int
    let hayinfo: Int
    let listado: ModeloNotificacionListado
}

struct ModeloNotificacionListado: Codable {
    let currentPage: Int
    let data: [NotificationesPager]
    let firstPageURL: String
    let from: Int
    let lastPage: Int
    let lastPageURL: String
    let nextPageURL: String?
    let path: String
    let perPage: Int
    let prevPageURL: String?
    let to: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to
        case total
    }
}

struct NotificationesPager: Identifiable, Codable, Equatable {
    let id: Int         // Asegúrate de que este campo sea único
    let idUsuario: Int
    let idTipoNotificacion: Int
    let fecha: String
    let imagen: String?
    let hayimagen: Int
    let titulo: String

    enum CodingKeys: String, CodingKey {
        case id
        case idUsuario = "id_usuario"
        case idTipoNotificacion = "id_tipo_notificacion"
        case fecha
        case imagen
        case hayimagen
        case titulo
    }
}
