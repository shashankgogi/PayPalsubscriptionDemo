//
//  General.swift
//  iOS_API_UpswingPlug
//
//  Created by macbook pro on 27/07/18.
//  Copyright © 2018 Omni-Bridge. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class General : UIViewController {
    /// Used to locally validate enter email adress.
    ///
    /// - Parameter testStr: email address
    /// - Returns: result
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /// Used to check connectivity
    ///
    /// - Returns: flag
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let isConnected = (isReachable && !needsConnection)
        
        return isConnected
    }
    
   /// Used to create alert
   ///
   /// - Parameters:
   ///   - title: titke
   ///   - message: message
   /// - Returns: alertview
   static func createAlert(title : String , message : String) -> UIAlertController{
        let alertVC = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
        alertVC.addAction(okAction)
        return alertVC
    }
    
    /// Used to present request alert message
    ///
    /// - Parameters:
    ///   - vc: viewcontroller
    ///   - message: message
    static func presenrRequestErrorAlert(vc : UIViewController , message : String){
        let alertVC = UIAlertController(title: "Opps" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
        alertVC.addAction(okAction)
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    
    /// Used to check for null value
    ///
    /// - Parameter value: value
    /// - Returns: result
    static func Check_null_values(value:Any!) -> Bool {
        if value is NSNull {
            return true
        }
        if value == nil {
            return true
        }
        if value is String && ((value as! String) == "(null)" || (value as! String) == "<null>"  || (value as! String) == "" || (value as! String) == "null") {
            return true
        }
        return false
    }
    
    /// Used to save image locally
    ///
    /// - Parameter image: image
    /// - Returns: result
    static func saveImage(image: UIImage) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("Profile.png")!)
            return true
        } catch  {
            print(error.localizedDescription)
            return false
        }
    }
    
    /// Used to get saved image
    ///
    /// - Parameter named: image name
    /// - Returns: image
    static func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    /// Used to calculate heighr for cell at indexpath
    ///
    /// - Parameter string: given string
    /// - Returns: height of cell at indexpath
    class func heightForString(_ string : String , width : CGFloat , fontSize : CGFloat) -> CGFloat{
        let attrString = NSAttributedString(string: string, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)])
        let rect : CGRect = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        return rect.height
    }
    
    /// Used to get formated date
    ///
    /// - Parameters:
    ///   - timeStamp: timeStamp
    ///   - formator: formator type
    /// - Returns: formated date
    class func getDateFromTimeStamp(timeStamp : Double , formator : String) -> String {
        let date = NSDate(timeIntervalSince1970: timeStamp)
        if formator == ".Short"{
            let messageDate = Date.init(timeIntervalSince1970: TimeInterval(timeStamp))
            let dataformatter = DateFormatter.init()
            dataformatter.timeStyle = .short
            let date = dataformatter.string(from: messageDate)
            return date
        }
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = formator
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
}

/// class for Constants
class Constant : NSObject{
    static let TAKE_COUNT = 1
    static var isOffLineModeON = false
}

/// class for Alert Messages Constant
class AlertMessagesConstant{
    static let NO_INTERNET_TITLE = "No Internet !"
    static let NO_INTERNET_MSG = "Please check your connection."
    static let DELETE_MSG = "Are you sure to delete downloaded content?."
    static let WARNING_TITLE = "Warning!"
    static let CANNOT_DELETE_MSG = "You can not delete the sub category while downloading."
    static let COMMENT_WARNING_MSG = "Comment text can't be blank."
    static let EMAIL_VALIDATE_MSG = "Enter valid email address."
    static let PASSWORD_WARNING_MSG = "Password can't be blank."
    static let FAILED_TITLE = "Failed !"
    static let SUCCESS_TITLE = "Success !"
    static let EMAIL_OR_PASSWORD_WRONG_MSG = "Email or Password may be incorrect."
    static let SOMETHING_WENT_WRONG_MSG = "Something went wrong."
    static let SEND_OTP_MSG = "OTP has been resend on your register email address."
    static let OTP_INVALID_MSG = "Please enter a valid OTP."
    static let NAME_INVALID_MSG = "Please enter a valid name."
    static let MOBILE_NUMBER_INVALID_MSG = "Please enter a valid mobile number."
    static let USER_NOT_FOUND_MSG = "User not found."
    static let PASSWORD_VALIDATE_MSG = "Password must be in 6 -15 characters.."
    static let PASSWORD_SHOULD_MATCH_MSG = "Passwords should be same."
    static let EMAIL_EXIST_MSG = "This email already exist."
    static let FEEDBACK_BLANK_WARNING_MSG = "Feedback text can't be blank."
}

// MARK: - Extension user to covert Hex string into UIcolor
extension UIColor {
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension String {
    var isBackspace: Bool {
        let char = self.cString(using: String.Encoding.utf8)!
        return strcmp(char, "\\b") == -92
    }
}
