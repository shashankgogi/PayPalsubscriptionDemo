//
//  WebServiceClass.swift
//  InterviewAcer
//
//  Created by OB on 03/07/18.
//  Copyright © 2018 OB. All rights reserved.
//

import UIKit

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


class WebServiceClass: NSObject {

    let Base_url = "http://114.143.198.154:8393/api/Subscription/"
    
    /**
     This function is used to perform **POST** operations in web api call.
     
     - parameter requestStr: Web API Name.
     - parameter Accesstoken: User access token used for autherization.
     - parameter jsonData: POST data.
     
     */
    
    func performPost(requestStr: String, jsonData:Any!, completion: @escaping (_ data: Any?) -> Void) {
        
        if General.isConnectedToNetwork() {
            
            DispatchQueue.global(qos: .background).async {
                
                let urlStr = "\(self.Base_url)\(requestStr)"
                let targetURL = URL.init(string: urlStr)
                let request = NSMutableURLRequest(url: targetURL! as URL)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                var data = Data()
                if jsonData is String{
                    data = Data((jsonData as! String).utf8)
                }else{
                    data = self.convertJsonObjectToData(jsonData)
                }
                request.httpBody = data
                
                let sessionConfiguration = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfiguration)
                
                let task = session.dataTask(with: request as URLRequest) { (data, resp, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        var statusCode = 400
                        if let httpResponse = resp as? HTTPURLResponse
                        {
                            statusCode = httpResponse.statusCode
                            print("\(httpResponse.statusCode)")
                        }
                        
                        if (data != nil && statusCode == 200) {
                            
                            if let json = self.convertDataToJsonObject(data!){
                                completion(json)
                            }
                            
                        }else {
                            print(error ?? "error")
                            if data != nil{
                                if let json = self.convertDataToJsonObject(data!){
                                    completion(json)
                                }
                            }else{
                                completion(["statusCode":"30","message":"error","data":"Somthing went wrong"])
                            }
                        }
                    })
                    return()
                }
                
                task.resume()
            }
            
        }else{
            
            completion(["statusCode":"30","message":"error","data":"No internet connection"])
        }
        
    }
    
    
    /**
     This function is used to convert json object to data.
     */
    
    func convertJsonObjectToData(_ jsonObj:Any) -> Data! {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions.prettyPrinted)
            return data
        } catch let error {
            print(error)
            return nil
        }
    }
    
    /**
     This function is used to convert data object to json object.
     */
    
    func convertDataToJsonObject(_ data:Data) -> Any! {
        do {
            let data = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return data
        } catch let error {
            print(error)
            return nil
        }
    }
}
