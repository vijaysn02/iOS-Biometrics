//
//  BioMetricModel.swift
//  Biometric
//
//  Created by Vijay on 08/05/20.
//  Copyright © 2020 vijay. All rights reserved.
//

import Foundation
import LocalAuthentication

//MARK: - Biometric Request
struct BioMetricRequest {
    
    let contextSetup:ContextSetup
    let reUseDuration:Double
    let authType:AuthenticationType
    let authExpirationTimer:Double
    
    
}

struct ContextSetup {
    
    var localizedCancelTitle:String = "Cancel"
    var localizedFallbackTitle:String = "Fallback"
    var localizedReason:String = "The App needs your Authentication"

    init(localizedCancelTitle:String,localizedFallbackTitle:String,localizedReason:String) {
        self.localizedCancelTitle = localizedCancelTitle
        self.localizedFallbackTitle = localizedFallbackTitle
        self.localizedReason = localizedReason
    }
}

enum AuthenticationType {

    case bioMetricOnly
    case bioMetricwithPassCode
    
    var policy : LAPolicy {
     
        switch self {
      
        case .bioMetricOnly: return .deviceOwnerAuthenticationWithBiometrics
        case .bioMetricwithPassCode: return .deviceOwnerAuthentication
    
      }
        
    }
        
    
}

//MARK: - BioMetric Response
enum BioMetricResponse {
    
    case Success
    case UserCancel
    case AppCancel
    case AuthenticationFailed
    case NotEnrolled
    case CustomFallback
    case OtherErrors
    
}



