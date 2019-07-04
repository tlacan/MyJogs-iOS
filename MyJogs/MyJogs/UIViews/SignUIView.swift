//
//  SignUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 28/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI

struct SignUIView: View {
     @Environment(\.isPresented) var isPresented: Binding<Bool>?
    
    let engine: Engine?
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State var showingAlert: Bool = false
    @State var showingAlertMessage: String = ""
    @State var displayNotValidEmail = false
    @State var displayPasswordErrors = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SignUpNavBarView(engine: engine, action: { self.dismissView() })
                LottieUI(name: K.Lottie.run).background(SwiftUI.Color.yellow)
                HStack {
                    Text(L10n.Signup.Email.textfield).layoutPriority(999).frame(width: 100, alignment: .leading)
                    TextField($email, placeholder: Text(L10n.Common.Textfield.required), onEditingChanged: { (editing) in
                        if !editing {
                            self.displayNotValidEmail = !self.email.isValidEmail()
                        }
                    }).background(Color.clear, cornerRadius: 5.0)
                        .layoutPriority(1)
                    
                }.frame(minWidth: UIScreen.main.bounds.width - 40, maxWidth: UIScreen.main.bounds.width - 40)
                if displayNotValidEmail {
                    Text(L10n.Signup.Email.notvalid).foregroundColor(SwiftUI.Color.red)
                }
                
                Divider().foregroundColor(.black).padding(.bottom, 3)
                HStack {
                    Text(L10n.Signup.Password.textfield).layoutPriority(999).frame(width: 100, alignment: .leading)
                    
                    SecureField($password, placeholder: Text(L10n.Common.Textfield.required)).background(Color.clear, cornerRadius: 5.0)
                      .layoutPriority(1)
                }.frame(minWidth: UIScreen.main.bounds.width - 40, maxWidth: UIScreen.main.bounds.width - 40)
                
                Divider().foregroundColor(.black).padding(.bottom, 3)
                HStack {
                    Text(L10n.Signup.PasswordConfirm.textfield).layoutPriority(999).frame(width: 160, alignment: .leading)
                    SecureField($confirmPassword, placeholder: Text(L10n.Common.Textfield.required))
                        .background(Color.clear, cornerRadius: 5.0)
                        .layoutPriority(1)
                }.frame(minWidth: UIScreen.main.bounds.width - 40, maxWidth: UIScreen.main.bounds.width - 40)
                
                PasswordErrorView(password: password, confirmPassword: confirmPassword)
                
                HStack {
                    Spacer()
                    Button(action: { self.signUpAction() }) {
                        Text(L10n.Signup.Signup.button).color(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray)
                    }.disabled(!updateButtonState())
                    .padding(10)
                    .border(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray, width: 1, cornerRadius: 18)
                    Spacer()
                }.padding(.top, 20)
            }.padding([.leading, .trailing], 20)
        }.frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width)
        .background(SwiftUI.Color.yellow.edgesIgnoringSafeArea(.all))
        .presentation($showingAlert) {
            Alert(title: Text(""), message: Text(showingAlertMessage), dismissButton: .default(Text(L10n.Common.ok)))
        }
    }
    
    func signUpAction() {
        engine?.userService.signUp(email: self.email, password: self.password, onDone: { error in
            if let error = error {
                self.showingAlertMessage = error.localizedDescription
                self.showingAlert = true
            } else {
                self.dismissView()
            }
        })
    }
    func dismissView() {
        isPresented?.value = false
    }
    
    func updateButtonState() -> Bool {
        return email.isValidEmail() && !password.isEmpty && password == confirmPassword
    }
    
    func displayEmailErrorMessage() -> Bool {
        return true
    }
}

struct PasswordErrorView: View {
    let password: String
    let confirmPassword: String
    
    init(password: String, confirmPassword: String) {
        self.password = password
        self.confirmPassword = confirmPassword
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if password.count > 0 && password.count < 9 {
                Text(L10n.Signup.Password.notvalid).foregroundColor(SwiftUI.Color.red)
            }
            if password.count > 0 && confirmPassword.count > 0 && password != confirmPassword {
                Text(L10n.Signup.Password.different).foregroundColor(SwiftUI.Color.red)
            }
        }
    }
}

struct SignUpNavBarView: View {
    let engine: Engine?
    let action: () -> Void
    
    init(engine: Engine?, action: @escaping () -> Void) {
        self.engine = engine
        self.action = action
    }
    
    var body: some View {
        HStack {
            Spacer()
            Spacer()
            Text(L10n.Signup.title).font(Font.custom(K.Fonts.appTitleFont, size: 40))
            Spacer()
            Button(action: {
                self.action()
            }, label: {
                Text(L10n.Signup.Baritem.login).color(.black)
            }).padding(6)
                .border(SwiftUI.Color.black, width: 1, cornerRadius: 12)
        }
    }
}

#if DEBUG
struct SignUIView_Previews: PreviewProvider {
    static var previews: some View {
        SignUIView(engine: nil)
    }
}
#endif
