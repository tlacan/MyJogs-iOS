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
    
    static let maxPriority: Double = 999
    static let minPriority: Double = 1
    static let emailWidth: CGFloat = 100
    static let cornerRadiusValue: CGFloat = 5
    static let bottomPadding: CGFloat = 3
    static let topPadding: CGFloat = 20
    static let mainRadius: CGFloat = 18
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
            //VStack {
                 LoginNavBarView(engine: engine)
                 LottieUI(name: K.Lottie.run).background(SwiftUI.Color.yellow)
                 HStack {
                    Text(L10n.Login.Email.textfield).layoutPriority(LoginUIView.maxPriority).frame(width: LoginUIView.emailWidth, alignment: .leading)
                    TextField(L10n.Common.Textfield.required, text: $email)
                        .background(Color.clear)
                        .mask(RoundedRectangle(cornerRadius: LoginUIView.cornerRadiusValue))
                        .layoutPriority(LoginUIView.minPriority)
                 }.frame(minWidth: UIScreen.main.bounds.width - CGFloat(40),
                 maxWidth: UIScreen.main.bounds.width - CGFloat(40))
    
                Divider().foregroundColor(.black).padding(.bottom, LoginUIView.bottomPadding)
                 
                 HStack {
                    Text(L10n.Login.Password.textfield).layoutPriority(LoginUIView.maxPriority).frame(width: LoginUIView.emailWidth, alignment: .leading)
                 SecureField(L10n.Common.Textfield.required, text: $password)
                 .background(Color.clear)
                    .mask(RoundedRectangle(cornerRadius: LoginUIView.cornerRadiusValue))
                    .layoutPriority(LoginUIView.minPriority)
                 }.frame(minWidth: UIScreen.main.bounds.width - CGFloat(40),
                 maxWidth: UIScreen.main.bounds.width - CGFloat(40))
                
                 HStack {
                    Spacer()
                    Button(action: { self.loginAction() }) {
                    Text(L10n.Login.Login.button)
                        .foregroundColor(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray)
                    }.disabled(!updateButtonState())
                    .padding(10)
                    .border(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray, width: 1)
                        .mask(RoundedRectangle(cornerRadius: LoginUIView.mainRadius))
                    Spacer()
                 }.padding(.top, LoginUIView.topPadding)
            }.padding([.leading, .trailing], 20)
        }.frame(minWidth: UIScreen.main.bounds.width,
                maxWidth: UIScreen.main.bounds.width)
        .background(SwiftUI.Color.yellow.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
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
    static let textSize: CGFloat = 40
    var signView = SignUIView(engine: nil)
    
    init(engine: Engine?) {
        self.engine = engine
        signView = SignUIView(engine: engine)
    }
    
    var body: some View {
        HStack {
            
            Spacer()
            Spacer()
            Text(L10n.Login.title).font(Font.custom(K.Fonts.appTitleFont, size: LoginNavBarView.textSize))
            Spacer()
            NavigationLink(destination: signView, label: {
                Text(L10n.Login.Baritem.signup).foregroundColor(.black)
            }).padding(6)
                .border(SwiftUI.Color.black, width: 1)
                .mask(RoundedRectangle(cornerRadius: 12))
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
