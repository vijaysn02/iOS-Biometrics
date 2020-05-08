# Biometric Authentication

## Introduction:

This project is created to understand the working of Biometric Authentication and also to have a ready made component for integration in the projects. 

You can make use of Apple's Face ID and Touch ID for carrying out authentication in your app.

If you want to implement it straight away, you can do installation, configuration and copy the handler in the project and jump to the Usage part.

---------------------------------------------------------------------------------------------------

## Installation:

You need to include Local Authentication framework in your project.

----------------------------------------------------------------------------------------------------

## Configuration:

Include the Face Id privacy configuration in info.plist

```
<key>NSFaceIDUsageDescription</key>
<string>To Authenticate.</string>
```
----------------------------------------------------------------------------------------------------

## Coding Part - Handler:

There are three important section in this handler. (i) Initializing the Context  (ii) Evaluating the policy (iii) Fallback Mechanism

### Initializing the Context

```
    func initialContextSetup(contextSetup:ContextSetup,reUseDuration:Double) {
        
        context.localizedCancelTitle = contextSetup.localizedCancelTitle
        context.localizedFallbackTitle = contextSetup.localizedFallbackTitle
        context.localizedReason = contextSetup.localizedReason
        
        //Reuse duration - you can give your own duration in secs
        //context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
        context.touchIDAuthenticationAllowableReuseDuration = reUseDuration
    }
    
```

### Evaluating the policy

```
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
```

### Fallback Mechanism

```
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
```


----------------------------------------------------------------------------------------------------

## Helper Part

### Toast  is used for assisting the main functionality

----------------------------------------------------------------------------------------------------

## Usage Part

### Invoke the below specific function to use in your View Controller. 

```
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
```

### Subscribe to the Class delegate to get information in your View Controller 

```
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
```


### Check out my Post about Biometric Authentication : [Biometric Authentication](https://vijaysn.com/2020/04/23/ios-av-player/)
