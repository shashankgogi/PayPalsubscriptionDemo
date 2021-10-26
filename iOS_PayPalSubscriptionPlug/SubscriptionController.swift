//
//  ViewController.swift
//  iOS_SubscriptionPlug
//
//  Created by macbook pro on 20/11/18.
//  Copyright © 2018 Omni-Bridge. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl
import Braintree
import BraintreeDropIn

class SubscriptionController: UIViewController {
    
    // MARK:- Outlets & variable declaration
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    lazy var segmentedControl: ScrollableSegmentedControl = {
        var frame = CGRect()
        if self.view.bounds.height == 812{
            frame = CGRect(x: 16, y: (self.navigationController?.navigationBar.bounds.height)! + 50, width: self.view.bounds.width - 32, height: 50)
        }else{
            frame = CGRect(x: 16, y: (self.navigationController?.navigationBar.bounds.height)! + 25 , width: self.view.bounds.width - 32, height: 50)
        }
        let segView = ScrollableSegmentedControl(frame:frame)
        self.view.addSubview(segView)
        return segView
    }()
    
    let clientToken = "sandbox_dcy5zc94_2h32mkmcxrhx3x8x"
    var WebService = WebServiceClass()
    var subscriptionArr = NSArray()
    var selectedSubsPackageIndex = 0
    let imageCache = NSCache<AnyObject, AnyObject>()
    var isNeedToSetBackButton = false
    
    
    // MARK:- ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.isPagingEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if General.isConnectedToNetwork(){
            self.activityLoader.startAnimating()
            self.callSubscriptionAPI()
        }else{
            self.activityLoader.stopAnimating()
            self.activityLoader.isHidden = true
            General.presenrRequestErrorAlert(vc: self, message: "No Internet available. Please check your connectivity.!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK:- UIButton action methods
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        let inexPath = IndexPath(row: sender.selectedSegmentIndex, section: 0)
        collectionView.scrollToItem(at: inexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func subscribeBtnPressed(_ sender: UIButton) {
        
        if General.isConnectedToNetwork(){
            self.selectedSubsPackageIndex = sender.tag
            showDropIn(clientTokenOrTokenizationKey: clientToken)
        }else{
            General.presenrRequestErrorAlert(vc: self, message: "No Internet available. Please check your connectivity.!")
        }
        
    }
    
    @objc func backPressed(sender : Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Webservice Call
    
    func callSubscriptionAPI(){
        self.activityLoader.startAnimating()
        APIs.performGet(requestStr: "\(PathPrefix.SUBCRIPTION_NAME)/GetPackages", query: "userId=1005") { (data) in
            if let err = data as? Error{
                self.activityLoader.stopAnimating()
                self.activityLoader.isHidden = true
                General.presenrRequestErrorAlert(vc: self, message: err.localizedDescription)
                return
            }
            if let resp = data as? NSDictionary{
                if let subsArr = resp.value(forKey: "data") as? NSArray {
                    self.subscriptionArr = subsArr
                    print(subsArr)
                }
            }
            self.activityLoader.stopAnimating()
            self.activityLoader.isHidden = true
            
            self.collectionView.reloadData()
            if self.segmentedControl.numberOfSegments == 0{
                self.initializeSegmentController(segmentArr: self.subscriptionArr as NSArray)
            }
            self.segmentedControl.selectedSegmentIndex = self.selectedSubsPackageIndex
        }
    }
    
    func callPaymentAPI(nonceToken:String) {
        
        let dict = ["SubscriptionId":"\((self.subscriptionArr[self.selectedSubsPackageIndex] as! NSDictionary).value(forKey: "id") as? Int ?? 0)", "UserId":"1005", "NonceToken":nonceToken]
        WebService.performPost(requestStr: "Braintree", jsonData: dict) { (data) in
            self.activityLoader.stopAnimating()
            self.view.isUserInteractionEnabled = true
            let responseData = data as! [String:Any]
            
            if responseData["statusCode"] as? String == "10"{
                self.present(General.createAlert(title: "Alert", message: "Transaction sucessfull !!!"), animated: true, completion: nil)
                self.callSubscriptionAPI()
            }else{
                General.presenrRequestErrorAlert(vc: self, message: "\(responseData["data"] as! String)")                
            }
            
        }
        
    }
    
    //MARK: Userdefined Methods
    
    private func initializeSegmentController(segmentArr : NSArray){
        segmentedControl.segmentStyle = .textOnly
        if segmentArr.count != 0{
            for index in 0...(segmentArr.count - 1){
                let segObjDict = segmentArr[index] as! NSDictionary
                segmentedControl.insertSegment(withTitle: segObjDict.value(forKey: "platformName") as? String ?? "", image: nil, at: index)
            }
        }
        segmentedControl.underlineSelected = true
        segmentedControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        // modify ScrollableSegmentedControl color property
        segmentedControl.segmentContentColor = UIColor.black
        segmentedControl.selectedSegmentContentColor = UIColor.purple
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = UIColor.purple
        
        let largerRedTextSelectAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.purple]
        segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR----\(String(describing: error?.localizedDescription))")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                
                print(String(describing: result.paymentMethod?.nonce))
                DispatchQueue.main.async {
                    self.activityLoader.startAnimating()
                }
                self.callPaymentAPI(nonceToken: (result.paymentMethod?.nonce)!)
                //                Use the BTDropInResult properties to update your UI
                //                result.paymentOptionType
                //                result.paymentIcon
                //                result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    //MARK: Navogation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - UICollectionViewCell

/// Custom class for CollectionViewCell with outlets
class customCollectionView : UICollectionViewCell{
    @IBOutlet weak var lblForPrice: UILabel!
    @IBOutlet weak var lblForCurrencySymbol: UILabel!
    @IBOutlet weak var lblForDescription: UILabel!
    @IBOutlet weak var lblForTotalQues: UILabel!
    @IBOutlet weak var imgViewForIcon: UIImageView!
    @IBOutlet weak var btnForSubscribe: UIButton!
    @IBOutlet weak var viewForBackground: UIView!
    
    /// Removing added gradient
    func reset(){
        if let layers = self.viewForBackground.layer.sublayers{
            for layer in layers{
                if layer.name == "Plug"{
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}

// MARK: - UICollectionView Delegate
extension SubscriptionController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionView DataSource
extension SubscriptionController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subscriptionArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell",
                                                      for: indexPath) as! customCollectionView
        cell.reset()
        let segObjDict = self.subscriptionArr[indexPath.row] as! NSDictionary
        cell.lblForPrice.text = segObjDict.value(forKey: "amount") as? String ?? ""
        cell.lblForDescription.text = segObjDict.value(forKey: "packageName") as? String ?? ""
        if let quesCount = segObjDict.value(forKey: "totalQuestionCount") as? Int{
            if quesCount == 0{
                cell.lblForTotalQues.text = " "
            }else if quesCount < 11{
                cell.lblForTotalQues.text = "\(quesCount) Questions"
            }else if quesCount < 100{
                cell.lblForTotalQues.text = "\(Int(quesCount / 10) * 10)+ Questions"
            }else if quesCount > 100{
                cell.lblForTotalQues.text = "\(Int(quesCount / 100) * 100)+ Questions"
            }
        }
        if let imgUrlStr = segObjDict.value(forKey: "assetUrl") as? String{
            if let imageFromCache = imageCache.object(forKey: imgUrlStr as AnyObject) as? UIImage {
                cell.imgViewForIcon.image = imageFromCache
            }else{
                APIs.downloadImage(imageLink: imgUrlStr) { (image) in
                    self.imageCache.setObject(image, forKey: imgUrlStr as AnyObject)
                    DispatchQueue.main.async {
                        cell.imgViewForIcon.image = image
                    }
                }
            }
        }
        // setting property to button
        if segObjDict.value(forKey: "isSubscribed") as? Bool ?? false {
            cell.btnForSubscribe.isHidden = true
            cell.lblForCurrencySymbol.isHidden = true
            cell.lblForPrice.text = "SUBSCRIBED"
        }else if cell.lblForPrice.text == "0" || cell.lblForPrice.text == "0.0"{
            cell.lblForPrice.text = "FREE"
            cell.btnForSubscribe.isHidden = true
            cell.lblForCurrencySymbol.isHidden = true
        }else{
            cell.btnForSubscribe.isHidden = false
            cell.lblForCurrencySymbol.isHidden = false
            cell.btnForSubscribe.tag = indexPath.row
            cell.btnForSubscribe.addTarget(self, action: #selector(subscribeBtnPressed(_:)), for: .touchUpInside)
            cell.btnForSubscribe.setTitleColor(UIColor(hex: segObjDict.value(forKey: "color1") as? String ?? "#ff0000")!, for: .normal)
            cell.btnForSubscribe.layer.borderColor = UIColor(hex: segObjDict.value(forKey: "color1") as? String ?? "#ff0000")!.cgColor
            cell.btnForSubscribe.layer.shadowColor = UIColor(hex: segObjDict.value(forKey: "color1") as? String ?? "#ff0000")!.cgColor
            cell.btnForSubscribe.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.btnForSubscribe.layer.shadowRadius = 4
            cell.btnForSubscribe.layer.shadowOpacity = 0.9
        }
        // adding gradient
        let gradient = CAGradientLayer()
        gradient.name = "Plug"
        gradient.frame = cell.viewForBackground.bounds
        gradient.colors = [UIColor(hex: segObjDict.value(forKey: "color1") as? String ?? "#ff0000")!.cgColor, UIColor(hex: segObjDict.value(forKey: "color2") as? String ?? "#ff0000")!.cgColor]
        gradient.cornerRadius = 5
        cell.viewForBackground.layer.insertSublayer(gradient, at: 0)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            var visibleRect = CGRect()
            visibleRect.origin = self.collectionView.contentOffset
            visibleRect.size = self.collectionView.bounds.size
            let visiblePoint = CGPoint(x: visibleRect.midX , y: visibleRect.midY)
            guard let indexPath = self.collectionView.indexPathForItem(at: visiblePoint) else { return }
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.segmentedControl.selectedSegmentIndex = indexPath.row
            self.segmentedControl.segmentContentColor = UIColor.black
            self.segmentedControl.setNeedsDisplay()
        }
    }
    
}
