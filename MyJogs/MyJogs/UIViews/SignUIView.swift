//
//  SignUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 28/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI

struct SignUIView: View {
    var isPresented: Bool = false
    
    static let customPriority: Double = 999
    static let lowPriority: Double = 1
    static let customWidth: CGFloat = 100
    static let textFieldRadius: CGFloat = 5
    static let buttonRadius: CGFloat = 18
    static let widthSize = UIScreen.main.bounds.width - CGFloat(40)
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
                    Text(L10n.Signup.Email.textfield).layoutPriority(SignUIView.customPriority).frame(width: SignUIView.customWidth, alignment: .leading)
                    TextField(L10n.Common.Textfield.required, text: $email, onEditingChanged: { (editing) in
                        if !editing {
                            self.displayNotValidEmail = !self.email.isValidEmail()
                        }
                    }).background(Color.clear)
                        .mask(RoundedRectangle(cornerRadius: SignUIView.textFieldRadius))
                        .layoutPriority(SignUIView.lowPriority)
                    
                }.frame(minWidth: SignUIView.widthSize, maxWidth: SignUIView.widthSize)
                 
                if displayNotValidEmail {
                    Text(L10n.Signup.Email.notvalid).foregroundColor(SwiftUI.Color.red)
                }
                
                Divider().foregroundColor(.black).padding(.bottom, CGFloat(3))
                HStack {
                    Text(L10n.Signup.Password.textfield).layoutPriority(SignUIView.customPriority).frame(width: SignUIView.customWidth, alignment: .leading)
                    SecureField(L10n.Common.Textfield.required, text: $password).background(Color.clear)
                        .mask(RoundedRectangle(cornerRadius: SignUIView.textFieldRadius))
                        .layoutPriority(SignUIView.lowPriority)
                }.frame(minWidth: SignUIView.widthSize, maxWidth: SignUIView.widthSize)
                
                Divider().foregroundColor(.black).padding(.bottom, CGFloat(3))
                HStack {
                    Text(L10n.Signup.PasswordConfirm.textfield).layoutPriority(SignUIView.customPriority).frame(width: CGFloat(160), alignment: .leading)
                    SecureField(L10n.Common.Textfield.required, text: $confirmPassword)
                        .background(Color.clear)
                        .mask(RoundedRectangle(cornerRadius: SignUIView.textFieldRadius))
                        .layoutPriority(SignUIView.lowPriority)
                }.frame(minWidth: SignUIView.widthSize, maxWidth: SignUIView.widthSize)
                
                PasswordErrorView(password: password, confirmPassword: confirmPassword)
                
                HStack {
                    Spacer()
                    Button(action: { self.signUpAction() }) {
                        Text(L10n.Signup.Signup.button).foregroundColor(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray)
                    }.disabled(!updateButtonState())
                    .padding(10)
                    .border(updateButtonState() ? SwiftUI.Color.black : SwiftUI.Color.gray, width: 1)
                    .mask(RoundedRectangle(cornerRadius: SignUIView.buttonRadius))
                    Spacer()
                }.padding(.top, CGFloat(20))
            }.padding([.leading, .trailing], CGFloat(20))
        }.frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width)
        .background(SwiftUI.Color.yellow.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
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
        
        //isPresented = false
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
    let fontSize: CGFloat = 40
    
    init(engine: Engine?, action: @escaping () -> Void) {
        self.engine = engine
        self.action = action
    }
    
    var body: some View {
        HStack {
            Spacer()
            Spacer()
            
            Text(L10n.Signup.title).font(Font.custom(K.Fonts.appTitleFont, size: fontSize))
            Spacer()
            Button(action: {
                self.action()
            }, label: {
                Text(L10n.Signup.Baritem.login).foregroundColor(.black)
            }).padding(6)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 1))
        }
    }
}

#if DEBUG
struct SignUIView_Previews: PreviewProvider {
    static var previews: some View {
        SignUIView(isPresented: true, engine: nil)
    }
}
#endif
