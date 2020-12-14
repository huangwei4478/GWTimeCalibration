//
//  ViewController.swift
//  GWTimeCalibration
//
//  Created by huangwei on 2020/12/13.
//

import UIKit
import PKHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.timeStyle = .medium
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GWTimeCalibrationManager.TimerNotificationName), object: nil, queue: OperationQueue.main) { (notification) in
            if let currentTime = notification.userInfo?[GWTimeCalibrationManager.TimerNotificationUserInfoName] as? TimeInterval {
                self.currentTimeLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: currentTime / 1000))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: GWTimeCalibrationManager.TimerNotificationName), object: nil)
    }

    @IBAction func pressPushBackButton() {
        /**
            让校准的时间往后误差 5 秒钟，测试用
         */
        GWTimeCalibrationManager.shared().pushBackFiveSeconds()
    }
    
    @IBAction func pressCalibrateTimeButton(_ sender: Any) {
        HUD.hide()
        
        /**
         
            校准时间的时机：
                1. APP 启动时
                2. APP 从后台返回到前台的时候
                3. 这里手动触发
         */
        
        HUD.show(.progress)
        GWTimeCalibrationManager.shared().getServerTime { (timeInterval) in
            DispatchQueue.main.async {
                HUD.hide()
                HUD.flash(.labeledSuccess(title: "\(timeInterval)", subtitle: nil), delay: 0.6)
            }
        } failClosure: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                HUD.flash(.labeledError(title: error.localizedDescription, subtitle: nil), delay: 0.6)
            }
        }
    }
    
}

