//
//  WebViewRepresentable.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 21/10/24.
//

import SwiftUI
import WebKit

struct CustomWebView: UIViewRepresentable {
    @AppStorage(DatosGuardadosKeys.tamanoLetra) private var fontSize: Int = 20
    @AppStorage(DatosGuardadosKeys.tipoLetra) private var tipoLetraTexto: Int = 0
    @AppStorage(DatosGuardadosKeys.temaApp) private var temaApp: Int = 0

    var htmlContent: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        opcinicio(for: webView, coordinator: context.coordinator)
        
        loadHTMLContent(in: webView)
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Actualiza el tamaño de la fuente cada vez que se cambie el valor de fontSize
        let scriptTamano = "document.body.style.fontSize = '\(fontSize)px';"
        webView.evaluateJavaScript(scriptTamano, completionHandler: nil)
        
        print("LLEGA AQUII")
        
        // Actualiza la fuente de letra según el valor de tipoLetraTexto
        let tipoLetraScript = obtenerScriptParaFuente(tipoLetraTexto: tipoLetraTexto)
        webView.evaluateJavaScript(tipoLetraScript, completionHandler: nil)
    }

    private func opcinicio(for webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.add(coordinator, name: "didTapParagraph")
    }

    private func loadHTMLContent(in webView: WKWebView) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }

    private func obtenerScriptParaFuente(tipoLetraTexto: Int) -> String {
        switch tipoLetraTexto {
        case 0:
            return "document.body.style.fontFamily = 'Fuente1ios';"
        case 1:
            return "document.body.style.fontFamily = 'Fuente2ios';"
        case 2:
            return "document.body.style.fontFamily = 'Fuente3ios';"
        case 3:
            return "document.body.style.fontFamily = 'Fuente4ios';"
        case 4:
            return "document.body.style.fontFamily = 'Fuente5ios';"
        default:
            return "document.body.style.fontFamily = 'Fuente1ios';"
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CustomWebView

        init(_ parent: CustomWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let tipoLetraScript = parent.obtenerScriptParaFuente(tipoLetraTexto: parent.tipoLetraTexto)
            webView.evaluateJavaScript(tipoLetraScript, completionHandler: nil)

            let textColor = (parent.temaApp == 1) ? "white" : "black"
            let backgroundColor = (parent.temaApp == 1) ? "black" : "white"

            let scriptColor = "document.body.style.color = '\(textColor)';"
            webView.evaluateJavaScript(scriptColor, completionHandler: nil)

            let javascriptBackground = "document.body.style.backgroundColor = '\(backgroundColor)';"
            webView.evaluateJavaScript(javascriptBackground, completionHandler: nil)

            let scriptTamano = "document.body.style.fontSize = '\(parent.fontSize)px';"
            webView.evaluateJavaScript(scriptTamano, completionHandler: nil)

            let script = """
            document.getElementById('miParrafo').addEventListener('click', function() {
                window.webkit.messageHandlers.didTapParagraph.postMessage('miParrafo fue tocado');
            });
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "didTapParagraph" {
                if let body = message.body as? String {
                    print(body)
                }
            }
        }
    }
}
