//
//  CustomModal2ButtonView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI

struct CustomModal2ButtonView: View {
    @Binding var isActive: Bool
    var title: String
    var message: String
    var cancelAction: () -> Void
    var acceptAction: () -> Void
    
    var body: some View {
        ZStack {
            // Fondo semi-transparente
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isActive = false
                    }
                }
            
            // Contenedor del modal
            VStack(spacing: 20) {
                // Título del modal
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // Mensaje del modal
                Text(message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    // Botón de Cancelar
                    Button(action: {
                        withAnimation {
                            cancelAction()
                            isActive = false
                        }
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-cancelar"))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Botón de Aceptar
                    Button(action: {
                        withAnimation {
                            acceptAction()
                            isActive = false
                        }
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-aceptar"))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
    }
}


/*#Preview {
    CustomModal2ButtonView(isActive: .constant(true), title: "Titulo", message: "verificar numero", cancelAction: {}, acceptAction: {})
}*/
