//
//  InicioView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI

struct InicioView: View {
    
    @EnvironmentObject var idiomaSettings: IdiomaSettings
    @AppStorage(DatosGuardadosKeys.idToken) private var idToken:String = ""
    @AppStorage(DatosGuardadosKeys.idCliente) private var idCliente:String = ""
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp:Int = 0
    
    var body: some View {
        Text("Hello, 111!")
            
    }
}

#Preview {
    InicioView()
}
