//
//  LoginView.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 3/10/24.
//

import SwiftUI
import SwiftyJSON
import RxSwift
import Alamofire
import AlertToast

struct LoginPresentacionView: View {
    
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0
    @State private var boolPantallaRegistro: Bool = false
    @State private var boolPantallaLogin: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 15){
                    // Logo
                    Image("abba_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 40)
                    
                    Text(TextoIdiomaController.localizedString(forKey: "key-bienvenidos-a-mi-caminar-dios"))
                        .font(.custom("LiberationSans-Bold", size: 28))
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        boolPantallaRegistro = true
                    }) {
                        Text(TextoIdiomaController.localizedString(forKey: "key-registrarse"))
                            .font(.custom("LiberationSans-Bold", size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    .opacity(1.0)
                    .buttonStyle(NoOpacityChangeButtonStyle())
                    
                    Text(TextoIdiomaController.localizedString(forKey: "key-ya-tines-una-cuenta"))
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("cgrisv1"))
                        .padding(.top, 15)
                    
                    
                    Text(TextoIdiomaController.localizedString(forKey: "key-ingresar"))
                        .font(.custom("LiberationSans-Bold", size: 22))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .foregroundColor(.black)
                        .bold()
                        .onTapGesture {
                            boolPantallaLogin = true
                        }
                    
                    Text(TextoIdiomaController.localizedString(forKey: "key-levantando-el-ejercito"))
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top, 30)
                        .padding(.horizontal, 6)
                } //end-vstack
            } // end-scroll
            
            .navigationDestination(isPresented: $boolPantallaRegistro) {
                RegistroView()
            }
            .navigationDestination(isPresented: $boolPantallaLogin) {
                LoginView()
            }
        } // end-zstack
    } // end-body
    
    
} // end-view
