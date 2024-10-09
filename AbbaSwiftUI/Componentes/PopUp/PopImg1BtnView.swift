//
//  PopImg1BtnView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI

struct PopImg1BtnView: View {
    @Binding var isActive: Bool
    @Binding var imagen: String
    @Binding var bLlevaTitulo: Bool
    @Binding var titulo: String
    @Binding var descripcion: String
    @Binding var txtAceptar: String
    @State private var isPressed = false
        
    var acceptAction: () -> Void
    
    var body: some View {
        ZStack {
            // Fondo semi-transparente
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                       // isActive = false
                    }
                }
            
            // Contenedor del modal
            VStack(spacing: 10) {
                // Título del modal
                Image("infocolor")
                    .resizable()
                    .frame(width: 50, height: 50)
                
                if(bLlevaTitulo){
                    // Mensaje del modal
                    Text(titulo)
                        .font(.custom("LiberationSans-Bold", size: 18))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                
                // Mensaje del modal
                Text(descripcion)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 1)
                
                
                HStack {
                    
                    // Botón de Aceptar
                    Button(action: {
                        withAnimation {
                            acceptAction()
                            isActive = false
                        }
                    }) {
                        Text(txtAceptar)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("cazulv1"))
                            .cornerRadius(8)
                    }.padding(.top, 12)
                        .opacity(1.0)
                        .buttonStyle(NoOpacityChangeButtonStyle())
                }
                .padding(.horizontal, 7)
            }
            .padding(.bottom, 10)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
    }
}



#Preview {
    PopImg1BtnView(isActive: .constant(true), imagen: .constant("infocolor"), bLlevaTitulo: .constant(false),
                   titulo: .constant("Titulo"), descripcion: .constant("Ejemplo de descripcion de la aplicacion que se esta mostrando"), txtAceptar: .constant("Aceptar"),
                   acceptAction: {})
}
