//
//  ButtonView.swift
//  Jebreed
//
//  Created by Jevon Levin on 22/05/23.
//


import SwiftUI

struct ButtonView: View {
    var text: String
    var isPrimary: Bool = true
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isPrimary ? .blue : .gray)
            .cornerRadius(8)
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(text: "test")
    }
}
