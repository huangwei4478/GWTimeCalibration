//
//  GWCountDownApi.swift
//  GWTimeCalibration
//
//  Created by huangwei on 2020/12/13.
//

import Foundation

class GWCountDownApi {
    private static let session = URLSession.shared
    
    private static let getTimeUrl = URL(string: "http://127.0.0.1:7878")!
    
    static func getServerTime(completeClosure: @escaping (_ timeInterval: TimeInterval) -> (),
                              errorClosure: @escaping (Error) -> () ) {
        let task = session.dataTask(with: getTimeUrl) { (data, response, error) in
            if let error = error {
                errorClosure(error)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if ((200...299).contains(httpResponse.statusCode) == false) {
                        errorClosure(NSError(domain: "HTTP status code \(httpResponse.statusCode)", code: httpResponse.statusCode, userInfo: nil))
                    } else {
                        // HTTP status code 200, good to go
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Int64],
                               let timestamp_ms = json["timestamp_ms"] {
                                completeClosure(TimeInterval(timestamp_ms))
                            }
                        } catch let error {
                            errorClosure(error)
                        }
                    }
                } else {
                    errorClosure(NSError(domain: "unknown casting error from URLResponse to HTTPURLResponse", code: 0, userInfo: nil))
                }
            }
        }
        
        task.resume()
    }
}
