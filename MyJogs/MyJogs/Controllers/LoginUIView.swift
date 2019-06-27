//
//  LoginUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 27/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI
import Lottie

struct LoginUIView: View {
    let engine: Engine?
    @State var email: String = "" {
        didSet {
            updateButtonState()
        }
    }
    @State var password: String = "" {
        didSet {
            updateButtonState()
        }
    }
    @State var enableButton: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField($email)
                TextField($password)
                Button(action: {
                    self.engine?.userService.login()
                }) {
                    Text(L10n.Login.Login.button)
                }
                LottieUI()
            }
            .navigationBarTitle(Text("View Controller Records"), displayMode: .inline)
            
        }
    }
    
    func updateButtonState() {
        enableButton = !email.isEmpty && !password.isEmpty
    }
}

struct LottieUI: UIViewRepresentable {
    static let kLottieName = "run"
    func makeUIView(context: UIViewRepresentableContext<LottieUI>) -> AnimationView {
        let lottieView = AnimationView(name: LottieUI.kLottieName)
        lottieView.animationSpeed = 1.0
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()
        
        return lottieView
    }
    
    func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<LottieUI>) {
        //to do
    }
}

#if DEBUG
struct LoginUIView_Previews: PreviewProvider {
    static var previews: some View {
        LoginUIView(engine: nil)
    }
}

struct LottieUI_Previews: PreviewProvider {
    static var previews: some View {
        LottieUI().previewLayout(.sizeThatFits)
    }
}
#endif
