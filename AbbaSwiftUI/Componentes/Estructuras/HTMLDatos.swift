//
//  HTMLDatos.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 16/10/24.
//

import Foundation
import SwiftUI
import WebKit

struct AttributedTextView: UIViewRepresentable {
    var htmlText: String
    var textColor: UIColor

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear // Hacer el fondo transparente
        textView.textColor = textColor
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let attributedString = try? NSAttributedString(data: Data(htmlText.utf8),
                                                          options: [.documentType: NSAttributedString.DocumentType.html],
                                                          documentAttributes: nil) {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            
            // Ajustar el tamaño de la fuente
            mutableAttributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: mutableAttributedString.length), options: []) { value, range, _ in
                if let font = value as? UIFont {
                    let resizedFont = font.withSize(font.pointSize * 1.5) // Ajusta el tamaño de la fuente
                    mutableAttributedString.addAttribute(.font, value: resizedFont, range: range)
                }
            }

            // Cambiar el color del texto a blanco
            mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: mutableAttributedString.length))
            
            uiView.attributedText = mutableAttributedString
        }
    }
}
