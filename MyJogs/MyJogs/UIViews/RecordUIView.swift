//
//  RecordUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI
import MapKit

struct RecordUIView: View {
    @EnvironmentObject var jogsService: JogsService
    @State var showingAlert = false
    let engine: Engine?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(jogsService.jogs.identified(by: \.id)) { jog in
                    RecordRow(jog: jog)
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
                        label: { Text("Create") }
                    )
            )
            .presentation($showingAlert) {
                Alert(title: Text(""), message: Text(L10n.Apierror.common), dismissButton: .default(Text(L10n.Common.ok)))
            }
        }.onAppear {
            self.jogsService.initDistancesIfNeeded()
        }
    }
}

struct RecordRow: View {
    var jog: JogModel
    var body: some View {
        HStack {
            MapView(jog: jog)
            VStack(alignment: .center) {
                HStack {
                    Text(jog.dateFormatted()).italic()
                    Spacer()
                    Text(jog.durationFormatted())
                }
                Divider()
                Text(jog.averageSpeed()).font(Font.system(size: 30)).bold().foregroundColor(SwiftUI.Color.black)
            }
        }.frame(minHeight: 200)
    }
}

struct MapView: UIViewRepresentable {
    var jog: JogModel
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let lat = ((jog.position.first?.lat ?? 0.0) - (jog.position.last?.lat ?? 0.0)) / 2.0
        let lon = ((jog.position.first?.lon ?? 0.0) - (jog.position.last?.lon ?? 0.0)) / 2.0
        let centerPosLat = jog.position.first?.lat ?? 0 + lat
        let centerPosLon = jog.position.first?.lon ?? 0 + lon
        let coordinate = CLLocationCoordinate2D(latitude: centerPosLat, longitude: centerPosLon)
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
    }
}


#if DEBUG
struct RecordUIView_Previews: PreviewProvider {
    static var previews: some View {
        RecordUIView(engine: nil)
    }
}
#endif
