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

struct LoginRegistroView: View {
        
    @State private var navegarRegistroView = false
    @State private var navegarLoginView = false
    @AppStorage(DatosGuardadosKeys.idiomaApp) private var idiomaApp: Int = 0
            
    
    var body: some View {
        NavigationStack {
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
                           idiomaApp = 1
                           
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
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("cgrisv1"))
                            .padding(.top, 15)
                        
                        Text(TextoIdiomaController.localizedString(forKey: "key-ingresar"))
                            .font(.custom("LiberationSans-Bold", size: 23))
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                            .foregroundColor(.black)
                            .bold()
                                                
                        Text(TextoIdiomaController.localizedString(forKey: "key-levantando-el-ejercito"))
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.top, 25)
                                                
                    } //end-vstack
                   
                   
                }
                
            
            } // end-zstack
       
            .navigationDestination(isPresented: $navigateToDetail) {
               // CodigoOtpView(initialTime: _segundosiphone, telefono: phoneNumber)
                                
              
            }
            .onAppear{
                
                print("IDIOMA APP \(idiomaApp)")
              
            }
            .navigationDestination(isPresented: $navigateToDetail) {
               // CodigoOtpView(initialTime: _segundosiphone, telefono: phoneNumber)
                
                CodigoOtpView(telefono: phoneNumber, startValue: _segundosiphone)
            }
        } // end-navigationStack
    } // end-body
    
    
    
    // ** FUNCIONES **
   

    
    
} // end-view

#Preview {
    LoginView()
}
