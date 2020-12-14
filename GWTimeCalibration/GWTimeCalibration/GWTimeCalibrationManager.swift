//
//  GWTimeCalibrationManager.swift
//  GWTimeCalibration
//
//  Created by huangwei on 2020/12/13.
//

import Foundation

/// 提供时间校准，精确度：100毫秒
final class GWTimeCalibrationManager {
    // MARK: Public instances
    public static let TimerNotificationName = "GWTimeCalibrationManagerNotificationName"
    
    public static let TimerNotificationUserInfoName = "currentTimeInterval"
    
    // MARK: Private instances
    
    /// 服务器时间（毫秒）
    private var serverTime: TimeInterval = 0.0
    
    /// 服务器和当前 APP 的时间差（毫秒）
    private var deltaTime: TimeInterval = 0.0
    
    /// 设置人工的误差，为了测试 (getServerTime的时候置零，在pushBackTime方法的时候设置成5秒)
    private var setBackTime: TimeInterval = 0.0
    
    /// 设置重试次数，最多重试3次
    private var retryCount: Int = 0
    
    /// singleton
    private static let _instance = GWTimeCalibrationManager()
        
    // MARK: Public Methods
    
    public static func shared() -> GWTimeCalibrationManager {
        return _instance
    }
    
    public func startTimer() {
        getServerTime(completeClosure: nil, failClosure: nil)
        
        GWGCDTimer.shared.scheduleDispatchTimer(name: "GWGCDTimer",
                                                timeInterval: 0.1,
                                                queue: .main,
                                                repeats: true) {
            let tempTotalTime = Date().timeIntervalSince1970 * 1000.0 + self.deltaTime - self.setBackTime
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GWTimeCalibrationManager.TimerNotificationName), object: nil, userInfo: [GWTimeCalibrationManager.TimerNotificationUserInfoName: tempTotalTime])
        }
    }
    
    public func getServerTime(completeClosure: ((TimeInterval) -> ())?, failClosure: ((Error) -> ())?) {
        GWCountDownApi.getServerTime { (currentTimeInterval) in
            DispatchQueue.main.async {
                self.calculateDeltaTime(serverTime: currentTimeInterval)
                completeClosure?(currentTimeInterval)
            }
        } errorClosure: { (error) in
            if self.retryCount <= 2 {
                self.getServerTime(completeClosure: nil, failClosure: nil)
                self.retryCount += 1
            } else {
                failClosure?(error)
            }
        }
    }
    
    /// 将倒计时的时间往后退 5 秒
    public func pushBackFiveSeconds() {
        setBackTime += 5 * 1000.0
    }
    
    // MARK: Private Methods
    
    /// 计算时间差，并且把测试用的人为误差清零
    /// - Parameter serverTime, 毫秒
    private func calculateDeltaTime(serverTime: TimeInterval) {
        setBackTime = 0.0
        deltaTime = serverTime - Date().timeIntervalSince1970 * 1000.0
    }
    
}
