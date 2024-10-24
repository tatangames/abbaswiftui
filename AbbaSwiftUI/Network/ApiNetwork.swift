//
//  ApiNetwork.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import Foundation

let apiVersionApp = "v. 1.0.0"

/// utilizado cuando hay un nuevo servicio
let apiURLAppleStore = "https://apps.apple.com/app/nortego/idxxxxxx"

let baseUrl:String = "http://192.168.1.29:8080/api/"
let baseUrlImagen: String = "http://192.168.1.29:8080/storage/archivos/"


// **************** RUTAS ********************


let apiListadoMunicipios = baseUrl+"app/solicitar/listado/iglesias"
let apiRegistroUsuario = baseUrl+"app/registro/usuario/v2"
let apiLogin = baseUrl+"app/login"
let apiSolicitarCodigoPorCorreo = baseUrl+"app/solicitar/codigo/contrasena"
let apiVerificarCodigoDeCorreo = baseUrl+"app/verificar/codigo/recuperacion"
let apiResetPassword = baseUrl+"app/actualizar/nueva/contrasena/reseteo"
let apiInformacionAjustes = baseUrl+"app/solicitar/informacion/perfil"
let apiListadoNotificaciones = baseUrl+"app/notificaciones/listado"
let apiBorrarNotificaciones = baseUrl+"app/notificacion/borrarlistado"
let apiListaInsigniasPorGanar = baseUrl+"app/listado/insignias/faltantes"
let apiInformacionPerfil = baseUrl+"app/solicitar/informacion/perfil"
let apiActualizarPerfil = baseUrl+"app/actualizar/perfil/usuario"
let apiListadoMisPlanes = baseUrl+"app/plan/listado/misplanes"
let apiListadoBuscarPlanes = baseUrl+"app/buscar/planes/nuevos"
let apiInformacionPlanNuevo = baseUrl+"app/plan/seleccionado/informacion"
let apiIniciarPlanSolo = baseUrl+"app/plan/nuevo/seleccionar"
let apiListaAmigosIniciarPlan = baseUrl+"app/comunidad/listado/solicitud/aceptadas"
let apiIniciarPlanConAmigos = baseUrl+"app/comunidadplan/iniciar/plan/amigosiphone"
let apiBloqueFechas = baseUrl+"app/plan/misplanes/informacion/bloque"
let apiMisRespuestasParaCompartir = baseUrl+"app/plan/misplanes/preguntas/infocompartir"
let apiTextoDevocional = baseUrl+"app/plan/misplanes/cuestionario/bloque"
let apiListadoPreguntas = baseUrl+"app/plan/misplanes/preguntas/bloque"
