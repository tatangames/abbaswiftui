//
//  BibliaView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 7/10/24.
//

import SwiftUI

struct BibliaView: View {
    
    @Environment(\.colorScheme) var scheme: ColorScheme
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Theme = .light
    
    
    var body: some View {
        VStack{
            Text("Hello, 333!")
                .foregroundColor(temaApp == .dark ? .white : .black)
        }
        .background(Color.blue)
    }
}

#Preview {
    BibliaView()
}
