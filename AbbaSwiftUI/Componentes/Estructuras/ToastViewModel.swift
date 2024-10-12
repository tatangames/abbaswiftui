//
//  ToastViewModel.swift
//  AbbaSwiftUI
//
//  Created by Jonathan  Moran on 11/10/24.
//

import Foundation
import AlertToast
import SwiftUI

class ToastViewModel: ObservableObject {
    @Published var customToast: AlertToast? = nil
    @Published var showToastBool: Bool = false

    func showCustomToast(with mensaje: String, tipoColor: ToastColor) {
        let titleColor = tipoColor.color
        customToast = AlertToast(
            displayMode: .banner(.pop),
            type: .regular,
            title: mensaje,
            subTitle: nil,
            style: .style(
                backgroundColor: titleColor,
                titleColor: Color.white,
                subTitleColor: Color.blue,
                titleFont: .headline,
                subTitleFont: nil
            )
        )
        showToastBool = true
    }
}
