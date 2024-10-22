//
//  WebViewRepresentable.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 21/10/24.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    var htmlText: String
    var theme: Bool
    var currentFontSize: Int
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        var webView: WKWebView?
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
            injectInitialCSS(into: webView)
        }
        
        func injectInitialCSS(into webView: WKWebView) {
            let textColor = parent.theme ? "white" : "black"
            let backgroundColor = parent.theme ? "black" : "white"
            let fontFamily = getFontFamily(for: 0)  // Usando índice 0 como valor por defecto
            
            let css = """
                var style = document.createElement('style');
                style.id = 'custom-styles';
                style.textContent = `
                    html {
                        font-size: \(parent.currentFontSize)px !important;
                    }
                    body {
                        font-family: '\(fontFamily)' !important;
                        color: \(textColor) !important;
                        background-color: \(backgroundColor) !important;
                    }
                    body, body * {
                        font-size: inherit !important;
                        color: inherit !important;
                    }
                `;
                document.head.appendChild(style);
            """
            
            webView.evaluateJavaScript(css) { _, error in
                if let error = error {
                    print("Error al inyectar CSS inicial: \(error)")
                }
            }
        }
        
        func updateStyles(fontSize: Int) {
            guard let webView = self.webView else { return }
            
            let textColor = parent.theme ? "white" : "black"
            let backgroundColor = parent.theme ? "black" : "white"
            let fontFamily = getFontFamily(for: 0)
            
            let updateScript = """
                var style = document.getElementById('custom-styles');
                if (style) {
                    style.textContent = `
                        html {
                            font-size: \(fontSize)px !important;
                        }
                        body {
                            font-family: '\(fontFamily)' !important;
                            color: \(textColor) !important;
                            background-color: \(backgroundColor) !important;
                        }
                        body, body * {
                            font-size: inherit !important;
                            color: inherit !important;
                        }
                    `;
                }
            """
            
            webView.evaluateJavaScript(updateScript) { _, error in
                if let error = error {
                    print("Error al actualizar estilos: \(error)")
                }
            }
        }
        
        private func getFontFamily(for index: Int) -> String {
            switch index {
            case 0: return "Fuente1ios"
            case 1: return "Fuente2ios"
            case 2: return "Fuente3ios"
            case 3: return "Fuente4ios"
            case 4: return "Fuente5ios"
            default: return "Fuente1ios"
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        let wrappedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
        </head>
        <body>
            \(htmlText)
        </body>
        </html>
        """
        
        webView.loadHTMLString(wrappedHTML, baseURL: Bundle.main.bundleURL)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.updateStyles(fontSize: currentFontSize)
    }
}
