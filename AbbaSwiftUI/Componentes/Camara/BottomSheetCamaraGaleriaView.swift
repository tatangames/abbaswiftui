//
//  BottomSheetCamaraGaleriaView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI

struct BottomSheetCamaraGaleriaView: View {
    var onOptionSelected: (Int) -> Void
    
    var body: some View {
        VStack {
            Text("Opciones")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            Button(action: {
                // Acción para abrir la cámara
                onOptionSelected(2)
            }) {
                Text("Abrir cámara")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Acción para abrir la galería
                onOptionSelected(1)
            }) {
                Text("Abrir galería")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.height(200)]) // Ajusta la altura del bottom sheet
    }
}


