//
//  WebViewRepresentable.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 21/10/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlString: String
    let tamanoLetra: Int
    let temaApp: Int
    let onFinish: ((WKWebView) -> Void)?
    let onButtonMeditacionPressed: (() -> Void)?
    let onButtonTituloPressed: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Desactivar el zoom
         webView.scrollView.minimumZoomScale = 1.0
         webView.scrollView.maximumZoomScale = 1.0
         webView.scrollView.zoomScale = 1.0
        
        // Configurar el controlador de contenido
         let contentController = webView.configuration.userContentController
         
         // Agregar manejadores de mensajes
         contentController.add(context.coordinator, name: "didTapParagraph")
         contentController.add(context.coordinator, name: "buttonClicked") // Agregar aquí el manejador del botón

        
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.lastHtmlString != htmlString {
            uiView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            context.coordinator.lastHtmlString = htmlString
        }
        
        let scriptTamano = "document.body.style.fontSize = '\(tamanoLetra)px';"
        uiView.evaluateJavaScript(scriptTamano, completionHandler: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastHtmlString: String?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let scriptTamano = "document.body.style.fontSize = '\(parent.tamanoLetra)px';"
            webView.evaluateJavaScript(scriptTamano, completionHandler: nil)
            
            let textColor = (parent.temaApp == 1) ? "white" : "black"
            let backgroundColor = (parent.temaApp == 1) ? "black" : "white"
            
            let scriptColor = "document.body.style.color = '\(textColor)';"
            webView.evaluateJavaScript(scriptColor, completionHandler: nil)
            
            let javascriptBackground = "document.body.style.backgroundColor = '\(backgroundColor)';"
            webView.evaluateJavaScript(javascriptBackground, completionHandler: nil)
            
            // Agregar el script de clic al párrafo
            let javascriptTapScript = """
                document.getElementById('miParrafo').onclick = function() {
                    window.webkit.messageHandlers.didTapParagraph.postMessage("miParrafo tocado");
                };
            """
            webView.evaluateJavaScript(javascriptTapScript, completionHandler: nil)
            
            parent.onFinish?(webView)
        }
    }
}

// MARK: - Extensión para el manejo de mensajes

extension WebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "didTapParagraph" {
            if let body = message.body as? String {
                parent.onButtonTituloPressed?()
            }
        }
        
        if message.name == "buttonClicked", let messageBody = message.body as? String {
            parent.onButtonMeditacionPressed?()
        }
    }
 
}
