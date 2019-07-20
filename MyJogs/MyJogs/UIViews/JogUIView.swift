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
    @EnvironmentObject var locationService: LocationService
    let engine: Engine?
    static let targetSpeed: Double = 120
    
    @State var timerText: String = "00:00:00"
    @State var timer: Timer?
    @State var paused: Bool = false
    @State var date: Date = Date(timeIntervalSince1970: 0)
    @State var creationError: String?
    @State var showingAlert = false
    @State var retryMode: Bool = false
    var successClosure: (() -> Void)
    
    var body: some View {
        VStack(alignment: .center) {
            if retryMode {
                HStack(alignment: .center) {
                    JogButtonView(text: L10n.Jog.Save.button,
                                  color: SwiftUI.Color.green,
                                  action: { self.saveJog() })
                    JogButtonView(text: L10n.Jog.Cancel.button,
                                  color: SwiftUI.Color.red,
                                  action: { self.resetData() })
                }
            } else {
                if locationService.lastLocation != nil {
                    Text(L10n.Jog.Speed.label(String(currentSpeed()))).color(SwiftUI.Color.white).font(Font.system(size: 80))
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
            }
        }.frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
         .background(LinearGradient(gradient:
            Gradient(colors: [.black, gradientColor(), .black, .black, .black]),
                                    startPoint: .top, endPoint: .bottom), cornerRadius: 0)
        .presentation($showingAlert) {
                Alert(title: Text(""),
                      message: Text(creationError ?? L10n.Apierror.common),
                      dismissButton: .default(Text(L10n.Common.ok), onTrigger: {
                        self.retryMode = true
                        self.showingAlert = false
                }))
        }
    }
    
    func pauseTimer() {
        if !paused {
            timer?.invalidate()
            paused = true
            self.engine?.locationService.stopTracking(duration: nil)
            return
        }
        initTimer()
        paused = false
    }
    
    func gradientColor() -> Color {
        if locationService.lastLocation == nil {
            return .black
        }
        return isSpeedValid() ? .green : .red
    }
    
    func currentSpeed() -> Double {
        guard var speed = locationService.lastLocation?.speed else { return 0 }
        speed = speed * 3.6 // m/s => km/h
        return Double(round(10 * speed) / 10)
    }
    
    func isSpeedValid() -> Bool {
        let speed = currentSpeed()
        if speed > JogUIView.targetSpeed {
            return speed - (JogUIView.targetSpeed * 0.1) <= JogUIView.targetSpeed
        }
        return speed + (JogUIView.targetSpeed * 0.1) >= JogUIView.targetSpeed
    }
    
    func stopTimer() {
        engine?.locationService.stopTracking(duration: date)
        timer?.invalidate()
        saveJog()
    }
    
    func saveJog() {
        guard let currentJog = engine?.locationService.currentJog else { return }
        engine?.jogsService.createJog(currentJog, onDone: { (error) in
            if let error = error {
                self.showingAlert = true
                self.creationError = error.localizedDescription
                return
            }
            self.resetData()
            self.successClosure()
        })
    }
    
    func resetData() {
        retryMode = false
        timer = nil
        engine?.locationService.currentJog = nil
        timerText = "00:00:00"
        creationError = nil
    }
    
    func updateTimeString() {
        let df = Date.timeOnlyFormatter
        df.timeZone = TimeZone(secondsFromGMT: 0)
        timerText = df.string(from: date)
    }
    
    func initTimer() {
        let currentJog = engine?.locationService.currentJog ?? JogModel(id: nil,
                                            userId: engine?.userService.user?.userId ?? 0,
                                            position: [], beginDate: Date(), endDate: nil)
        self.engine?.locationService.startTracking(currentJog: currentJog)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
            self.date.addTimeInterval(time.timeInterval)
            self.updateTimeString()
        }
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
        JogUIView(engine: nil, successClosure: {})
    }
}
#endif
