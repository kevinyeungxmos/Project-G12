import SwiftUI

struct Checkboxstyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack{
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.black)
                configuration.label
            }
        }).tint(.white)
    }
}
