//
//  RecordUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI

struct RecordUIView: View {
    @EnvironmentObject var jogsService: JogsService
    @State var showingAlert = false
    let engine: Engine?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jogsService.jogs.identified(by: \.id)) { jog in
                    Text("Cell \(String(jog.id ?? 0))")
                }
            }
            .navigationBarTitle(Text("View Controller Records"), displayMode: .inline)
            .navigationBarItems(
                    trailing:
                    Button(
                    action: { self.jogsService.createJog(self.jogsService.createRandomModel(), onDone: { error in
                        if error != nil {
                            self.showingAlert = true
                        }
                    })
                    },
                        label: { Text("Créeer") }
                    )
            )
            .presentation($showingAlert) {
                Alert(title: Text(""), message: Text("Une erreur est survenur"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct RecordRow: View {
    var text: String
    var body: some View {
        Text("Jambon")
    }
}

#if DEBUG
struct RecordUIView_Previews: PreviewProvider {
    static var previews: some View {
        RecordUIView(engine: nil)
    }
}
#endif
