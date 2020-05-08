//
//  Biometrics.swift

//  Created by Vijay on 22/02/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import UIKit
import LocalAuthentication

//MARK: - Protocol
protocol BioMetricDelegate {
    func observeBioMetricResponse(response:BioMetricResponse,bioMetryType:String)
}

//MARK: - Initial Settings
class Biometrics {
    
    var context = LAContext()
    var bioMetryType = "Face ID"
    var vc = UIViewController()
    var delegate:BioMetricDelegate?
    
    init(request:BioMetricRequest,parentVC:UIViewController) {
        initialize(bioMetricRequest: request,parentVC:parentVC)
    }
    func initialize(bioMetricRequest:BioMetricRequest,parentVC:UIViewController) {
    
        vc = parentVC
        
        initialContextSetup(contextSetup: bioMetricRequest.contextSetup,reUseDuration: bioMetricRequest.reUseDuration)
        expiryTimerSetup(timer: bioMetricRequest.authExpirationTimer)
        findBiometryType()
        evaluatePolicy(type: bioMetricRequest.authType.policy)
        
    }
    func initialContextSetup(contextSetup:ContextSetup,reUseDuration:Double) {
        
        context.localizedCancelTitle = contextSetup.localizedCancelTitle
        context.localizedFallbackTitle = contextSetup.localizedFallbackTitle
        context.localizedReason = contextSetup.localizedReason
        
        //Reuse duration - you can give your own duration in secs
        //context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
        context.touchIDAuthenticationAllowableReuseDuration = reUseDuration
    }
    
}


//MARK: - Evaluating the Policy
extension Biometrics {
    
    func evaluatePolicy(type:LAPolicy) {
        var errorEvaluation:NSError?
        
        //Checking whether device can evaluate policy
        if context.canEvaluatePolicy(type, error: &errorEvaluation) {
            
        
            //Evaluating the policy
            context.evaluatePolicy(type, localizedReason: "Fallback title") { (success, error) in
                
                //Handling the Success
                if success {
                    self.delegate?.observeBioMetricResponse(response: .Success, bioMetryType: self.bioMetryType)
                }
                
                //Handling the Error
                if let err = error {
                    
                    let valError = LAError(_nsError: err as NSError)
                    switch valError.code {
                    case LAError.Code.userCancel:
                        self.delegate?.observeBioMetricResponse(response: .UserCancel, bioMetryType: self.bioMetryType)
                    case LAError.Code.appCancel:
                        self.delegate?.observeBioMetricResponse(response: .AppCancel, bioMetryType: self.bioMetryType)
                    case LAError.Code.userFallback:
                        self.delegate?.observeBioMetricResponse(response: .CustomFallback, bioMetryType: self.bioMetryType)
                    case LAError.Code.authenticationFailed:
                        self.delegate?.observeBioMetricResponse(response: .AuthenticationFailed, bioMetryType: self.bioMetryType)
                    default:
                        self.delegate?.observeBioMetricResponse(response: .OtherErrors, bioMetryType: self.bioMetryType)
                    }
                }
            }
            
    
        } else {
            
            print("cannot Evaluate")
            if let err = errorEvaluation {
                
                let valError = LAError(_nsError: err as NSError)
                switch valError.code {
                case LAError.Code.biometryNotEnrolled:
                    openSettingsforEnrollment()
                default:
                    print("other errors")
                }
            }
            
        }
    
    }
    func findBiometryType() {
        
        switch context.biometryType {
            
        case .faceID:
            bioMetryType = "Face ID"
        case .touchID:
            bioMetryType = "Touch ID"
        case .none:
            bioMetryType = "None"
        @unknown default:
            bioMetryType = "Unknown"
            
        }
        
        
    }
    
}

//MARK: - Fall back mechanism
extension Biometrics {
    
    func expiryTimerSetup(timer:Double) {
        if timer != 0.0 {
            Timer.scheduledTimer(withTimeInterval: timer, repeats: false) { (time) in
                self.context.invalidate()
            }
        }
    }
    func openSettingsforEnrollment() { 
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
        
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url,options: [:],completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { UIAlertAction in }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title:"Biometrics", message: "Please enroll your Face ID and Touch ID", preferredStyle: .alert)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.vc.present(alert, animated: true, completion: nil)
        }
        
    }
    
}


