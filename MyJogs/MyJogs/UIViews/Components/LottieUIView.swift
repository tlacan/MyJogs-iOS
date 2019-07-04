//
//  LottieUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 28/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI
import Lottie

struct LottieUI: UIViewRepresentable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieUI>) -> AnimationView {
        let lottieView = AnimationView(name: name)
        lottieView.animationSpeed = 1.0
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()
        lottieView.backgroundColor = .clear
        return lottieView
    }
    
    func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<LottieUI>) {
    }
}

#if DEBUG
struct LottieUI_Previews : PreviewProvider {
    static var previews: some View {
        LottieUI(name: K.Lottie.run)
    }
}
#endif
