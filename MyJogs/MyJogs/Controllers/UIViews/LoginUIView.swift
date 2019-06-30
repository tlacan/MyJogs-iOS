//
//  LoginUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 27/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI

struct LoginUIView: View {
    let engine: Engine?
    @State private var email: String = ""
    @State private var password: String = ""
    @State var showingAlert: Bool = false
    @State var showingAlertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                 LoginNavBarView(engine: engine)
                 LottieUI(name: K.Lottie.run).background(SwiftUI.Color.yellow)
                 HStack {
                    Text(L10n.Login.Email.textfield).layoutPriority(999).frame(width: 100, alignment: .leading)
                    TextField($email, placeholder: Text(L10n.Common.Textfield.required))
                        .background(Color.clear, cornerRadius: 5.0)
                        .layoutPriority(1)
                 }.frame(minWidth: UIScreen.main.bounds.width - 40,
                 maxWidth: UIScreen.main.bounds.width - 40)
    
                 Divider().foregroundColor(.black).padding(.bottom, 3)
                 
                 HStack {
                 Text(L10n.Login.Password.textfield).layoutPriority(999).frame(width: 100, alignment: .leading)
                 SecureField($password, placeholder: Text(L10n.Common.Textfield.required))
                 .background(Color.clear, cornerRadius: 5.0)
                 .layoutPriority(1)
                 }.frame(minWidth: UIScreen.main.bounds.width - 40,
                 maxWidth: UIScreen.main.bounds.width - 40)
                
                 HStack {
                    Spacer()
                    Button(action: { self.loginAction() }) {
                    Text(L10n.Login.Login.button)
                        .color(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray)
                    }.disabled(!updateButtonState())
                    .padding(10)
                    .border(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray, width: 1,
                            cornerRadius: 18)
                    Spacer()
                 }.padding(.top, 20)
            }.padding([.leading, .trailing], 20)
        }.frame(minWidth: UIScreen.main.bounds.width,
                maxWidth: UIScreen.main.bounds.width)
        .background(SwiftUI.Color.yellow.edgesIgnoringSafeArea(.all))
        .presentation($showingAlert) {
            Alert(title: Text(""),
                  message: Text(showingAlertMessage),
                  dismissButton: .default(Text(L10n.Common.ok)))
        }
    }
    
    func loginAction() {
        engine?.userService.login(email: self.email, password: self.password, onDone: { error in
            if let error = error {
                self.showingAlertMessage = error.localizedDescription
                self.showingAlert = true
            }
        })
    }

    func updateButtonState() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
}

struct LoginNavBarView: View {
    let engine: Engine?
    
    init(engine: Engine?) {
        self.engine = engine
    }
    
    var body: some View {
        HStack {
            Spacer()
            Spacer()
            Text(L10n.Login.title).font(Font.custom(K.Fonts.appTitleFont, size: 40))
            Spacer()
            PresentationButton(destination: SignUIView(engine: engine), label: {
                Text(L10n.Login.Baritem.signup).color(.black)
            }).padding(6)
                .border(SwiftUI.Color.black, width: 1, cornerRadius: 12)
        }
    }
}

#if DEBUG
struct LoginUIView_Previews: PreviewProvider {
    static var previews: some View {
        LoginUIView(engine: nil)
    }
}

#endif
