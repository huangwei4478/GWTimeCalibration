//
//  GWGCDTimer.swift
//  GWTimeCalibration
//
//  Created by huangwei on 2020/12/13.
//

import Foundation

class GWGCDTimer {
    
    /// Swift Singleton
    private static let _shared = GWGCDTimer()
    
    static var shared: GWGCDTimer {
        get {
            return _shared
        }
    }
    
    /// instance
    private var timerContainer: [String: DispatchSourceTimer]
    
    init() {
        timerContainer = [String: DispatchSourceTimer]()
    }
    
    func scheduleDispatchTimer(name: String,
                               timeInterval: Double,
                               queue: DispatchQueue,
                               repeats: Bool,
                               action: @escaping () -> ()) {
        if !timerContainer.keys.contains(name) {
            let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
            timer.resume()
            timerContainer[name] = timer
        }
        
        if let timer = timerContainer[name] {
            timer.schedule(deadline: .now(), repeating: timeInterval, leeway: DispatchTimeInterval.milliseconds(100))
            timer.setEventHandler {
                [weak self] in
                action()
                if repeats == false { self?.cancelTimer(name: name) }
            }
        }
        
    }
    
    func cancelTimer(name: String) {
        if let timer = timerContainer[name] {
            timerContainer.removeValue(forKey: name)
            timer.cancel()
        }
    }
    
}
