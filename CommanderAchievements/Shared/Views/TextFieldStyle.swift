//
//  TextFieldStyle.swift
//  GameAchievementsiOS
//
//  Created by jason debottis on 1/29/24.
//

import Foundation
import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }
}
