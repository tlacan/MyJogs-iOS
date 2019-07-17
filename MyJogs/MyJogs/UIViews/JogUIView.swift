//
//  JogUIView.swift
//  MyJogs
//
//  Created by thomas lacan on 04/07/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import SwiftUI
import CoreLocation

struct JogUIView: View {
    @EnvironmentObject var jogsService: JogsService
    let engine: Engine?
    
    @State var timerText: String = "00:00:00"
    @State var timer: Timer?
    @State var paused: Bool = false
    @State var date: Date = Date(timeIntervalSince1970: 0)
    @State var speed: Double = 0
    
    var body: some View {
        VStack(alignment: .center) {
            if timer != nil && !paused {
                Text(L10n.Jog.Speed.label(String(speed))).color(SwiftUI.Color.white).font(Font.system(size: 80))
            }
            Text(timerText).color(SwiftUI.Color.white).font(Font.system(size: 60))
            HStack(alignment: .center) {
                if timer == nil {
                    JogButtonView(text: L10n.Jog.Start.button, color: SwiftUI.Color.green,
                                  action: { self.initTimer() })
                } else {
                    JogButtonView(text: paused ? L10n.Jog.Resume.button : L10n.Jog.Pause.button,
                                  color: SwiftUI.Color.yellow,
                                  action: { self.pauseTimer() })
                    JogButtonView(text: L10n.Jog.Stop.button,
                                  color: SwiftUI.Color.red,
                                  action: { self.stopTimer() })
                }
            }
        }.onAppear {
            //self.engine?.locationService.register(observer: self)
        }.onDisappear {
            self.engine?.locationService.unregister(observer: self)
        }.frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
         .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func pauseTimer() {
        if !paused {
            timer?.invalidate()
            paused = true
            self.engine?.locationService.stopTracking()
            return
        }
        initTimer()
        paused = false
    }
    
    func stopTimer() {
        self.engine?.locationService.stopTracking()
        timer?.invalidate()
    }
    
    func updateTimeString() {
        timerText = Date.timeOnlyFormatter.string(from: date)
    }
    
    func initTimer() {
        self.engine?.locationService.register(observer: self)
        self.engine?.locationService.startTracking()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
            self.date.addTimeInterval(time.timeInterval)
            self.updateTimeString()
        }
    }
}

extension JogUIView: LocationServiceObserver {
    func locationService(locationService: LocationService, didUpdateLocation location: CLLocation?) {
        return
    }
    func locationService(locationService: LocationService, didChangeAuthorization status: CLAuthorizationStatus) {
        return
    }
    func loactionService(locationService: LocationService, didChangeSpeed speed: CLLocationSpeed) {
        self.speed = speed
    }
}


struct JogButtonView: View {
    let action: () -> Void
    let text: String
    let color: SwiftUI.Color
    
    init(text: String, color: SwiftUI.Color, action: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: { self.action() }) {
            Text(text).color(color).padding(30)
        }.background(color.opacity(0.3))
            .frame(width: 130)
            .mask(Circle())
    }
}

#if DEBUG
struct JogUIView_Previews: PreviewProvider {
    static var previews: some View {
        JogUIView(engine: nil)
    }
}
#endif
