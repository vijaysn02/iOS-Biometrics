//
//  ViewController.swift
//  API Master
//
//  Created by Vijay on 03/05/20.
//  Copyright © 2020 vijay. All rights reserved.
//

import UIKit


//MARK: - ViewController - Initialization
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        useBiometrics()
    }
    func useBiometrics() {
       
        //localizedCancelTitle - custom cancel button title
        //localizedFallbackTitle - custom Fallback label title
        //localizedReason - custom reason for usage of biometric
        let contextSetup = ContextSetup(localizedCancelTitle: "Cancel", localizedFallbackTitle: "Fallback", localizedReason: "The app needs your authentication")
        
        //contextSetup - to set the context for biometry
        //reUseDuration - enabling the user to reuse the same authentication for x secs
        //authType - to choose between bioMetricOnly and bioMetricwithPassCode
        //authExpirationTimer - default 0.0 (no deadline) - give custom deadline for finishing authentication if needed.
        let bioMetricRequest = BioMetricRequest(contextSetup: contextSetup, reUseDuration: 60.0, authType: .bioMetricOnly,authExpirationTimer: 0.0)
    
        let biometric = Biometrics(request: bioMetricRequest,parentVC: self)
        biometric.delegate = self
        
    }
    
}

//MARK: - BioMetric Delegate
extension ViewController:BioMetricDelegate {
   
    func observeBioMetricResponse(response: BioMetricResponse, bioMetryType: String) {
        
        switch response {
        case .Success:
            print("Authenticated")
        case .UserCancel:
            print("User cancelled Authentication")
        case .AppCancel:
            print("App cancelled Authentication")
        case .NotEnrolled:
            print("Device not Enrolled")
        case .AuthenticationFailed:
            print("Authentication failed")
        case .CustomFallback:
            DispatchQueue.main.async {
                self.customFallBack()
            }
        default:
            print("Other Error")
        }
        
    }
    
}

//MARK: - Custom Fall back
extension ViewController {
    
    func customFallBack() {
        
        let alertController = UIAlertController(title:"Authentication",message: "Enter your Auth Code",preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter the Auth Code"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (ok) in
            if let textField = alertController.textFields?.first {
                if let passCode = textField.text {
                    Toast.showasync(message: passCode, controller: self)
                } else {
                    Toast.showasync(message: "No pass code", controller: self)
                }
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)

    }
    
}
