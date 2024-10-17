//
//  GlobalVariablesSettings.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 16/10/24.
//

import Foundation

class GlobalVariablesSettings: ObservableObject {
    @Published var selectedBuscarPlanID: Int = 0
    
    // para actualizar los Tabs de Devocional
    @Published var updateTabsBuscarPlan: Bool = false
    @Published var updateTabsMiPlan: Bool = false
}
