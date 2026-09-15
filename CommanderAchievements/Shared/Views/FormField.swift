//
//  FormField.swift
//  GameAchievementsiOS
//
//  Created by jason debottis on 2/7/24.
//

import SwiftUI

struct FormField: View {
    var label: String
    var systemImage: String
    var binding: Binding<String>
    var isSecureFielfd: Bool = false
    @State var passwordShown: Bool = false
    var body: some View {
        VStack {
            Label(label, systemImage: systemImage)
                .foregroundColor(Color.white)
            if isSecureFielfd {
                HStack {
                    if passwordShown {
                        TextField("", text: binding)
                            .textFieldStyle(CustomTextFieldStyle())
                        Image(systemName: "eye")
                            .gesture(TapGesture().onEnded({ _ in
                                passwordShown = !passwordShown
                            }))
                    } else {
                        SecureField("", text: binding).textFieldStyle(CustomTextFieldStyle())
                        Image(systemName: "eye.slash")
                            .gesture(TapGesture().onEnded({ _ in
                                passwordShown = !passwordShown
                            }))
                    }
                }
                .formField()
                
            } else {
                HStack {
                    TextField("", text: binding)
                        .textFieldStyle(CustomTextFieldStyle())
                }.formField()
                
            }
        }
        
    }
}

#Preview {
    HStack {
        FormField(label: "test",
                  systemImage: "lock.fill",
                  binding: .constant("test"),
                  isSecureFielfd: false)
    }
    .frame(width: .infinity, height: .infinity)
    .background {
        Color.red
    }
}

extension View {
    func formField() -> some View{
        self
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
    }
}
