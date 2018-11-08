//
//  APIHelper.swift
//  OAuth
//
//  Created by Mac OS X on 15/05/2017.
//  Copyright © 2017 Cygnis Media. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import RNCryptor
import SwiftyJSON

let theBarCodeAPIDomain = "https://thebarcode-qa.cygnismedia.com"
let barCodeDomainURLString = theBarCodeAPIDomain + "/"
let baseURLString = barCodeDomainURLString + "api/"
let clientId = "thebarcode-ios-app"
let clientScret = "a7024f16e0c8d6475c2f82c66a8f6d9d85380e63"
let grantTypePassword = "password"

typealias responseCompletionHandler = (_ response: Any?, _ serverError: ServerError?, _ error: Error?) -> Void

class APIHelper {
    
    static var shared = APIHelper()
    
    var oauthHandler: OAuth2Handler?
    var sessionManager: SessionManager?
    
    private var isEncryptionEnabled: Bool = false
    
    init() {
        if let user = Utility.shared.getCurrentUser(), user.accessToken.value.count > 0, user.refreshToken.value.count > 0 {
            self.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
        } else {
            self.setUpOAuthHandler(accessToken: nil, refreshToken: nil)
        }
    }
    
    func setUpOAuthHandler(accessToken: String?, refreshToken: String?) {

        if let sessionManager = sessionManager {
            if accessToken == nil && refreshToken == nil {
                sessionManager.session.invalidateAndCancel()
            } else {
                sessionManager.session.finishTasksAndInvalidate()
            }
            oauthHandler = nil
        }
        
        let session = SessionManager()
        
        if let accessToken = accessToken, let refreshToken = refreshToken {
            let authHandler = OAuth2Handler(clientID: clientId, clientSecret: clientScret, baseURLString: baseURLString, accessToken: accessToken, refreshToken: refreshToken)
            
            session.adapter = authHandler
            session.retrier = authHandler
        }
        
        sessionManager = session
    }
    
    func hitApi(params: [String : Any], apiPath: String, method: HTTPMethod, completion: @escaping responseCompletionHandler) -> DataRequest {
        
        var aParams = params
        aParams["device_id"] = Utility.shared.deviceId
        
        let headers = self.getGenericHeaders()
        
        if let sessionManager = sessionManager {
            let url = baseURLString + apiPath
            let request = sessionManager.request(url, method: method, parameters: aParams, encoding: URLEncoding.methodDependent, headers: headers).validate().responseJSON { (response: DataResponse<Any>) in
                self.parseResponse(response: response, completion: completion)
            }
            
            return request
        } else {
            fatalError("Please setup session manager before hitting api")
        }
    }
    
    func hitApi(params: [String : Any], apiPath: String, multipartParms: [String : Any], completion: @escaping responseCompletionHandler) {
        
        var aParams = params
        aParams["device_id"] = Utility.shared.deviceId
        
        if let sessionManager = sessionManager {
            let url = baseURLString + apiPath
            sessionManager.upload(multipartFormData: { (formData: MultipartFormData) in
                for (key, value) in multipartParms {
                    let object = value as! (data: Data, name: String, fileName: String, mimeType: String)
                    formData.append(object.data, withName: key, fileName: object.fileName, mimeType: object.mimeType)
                }
                
                for (key, value) in params {
                    let stringValue = "\(String(describing: value))"
                    let data = stringValue.data(using: .utf8)!
                    formData.append(data, withName: key)
                }
                
            }, to: url, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.parseResponse(response: response, completion: completion)
                    }
                case .failure(let encodingError):
                    debugPrint(encodingError)
                    completion(nil, nil, encodingError)
                }
            })
        } else {
            fatalError("Please setup session manager before hitting api")
        }
    }
    
    func parseResponse(response: DataResponse<Any>, completion: responseCompletionHandler) {
        switch response.result {
        case .success:
            
            if self.isEncryptionEnabled {
                if let responseResult = response.result.value as? [String : Any], let result = responseResult["result"] as? String {
                    
                    do {
                        let encryptedData = Data(base64Encoded: result)
                        let password = "9>E>VBa=X%;[5BX~=Q~K"
                        let decryptedData = try RNCryptor.decrypt(data: encryptedData!, withPassword: password)
                        
                        let json = try JSON.init(data: decryptedData)
                        if let responseDictionary = json.dictionaryObject {
                            completion(responseDictionary, nil, nil)
                        } else if let responseArray = json.arrayObject {
                            completion(responseArray, nil, nil)
                        } else {
                            let error = NSError(domain: "EncryptionError", code: 500, userInfo: [NSLocalizedDescriptionKey : "Unknown Error"])
                            completion(response.result.value, nil, error)
                        }
                        
                    } catch {
                        let error = NSError(domain: "EncryptionError", code: 500, userInfo: [NSLocalizedDescriptionKey : "Unknown Error"])
                        completion(response.result.value, nil, error)
                    }
                } else {
                    let error = NSError(domain: "EncryptionError", code: 500, userInfo: [NSLocalizedDescriptionKey : "Unknown Error"])
                    completion(response.result.value, nil, error)
                }
            } else {
                if let responseResult = response.result.value as? [String : Any] {
                    completion(responseResult, nil, nil)
                } else if let responseResult = response.result.value as? [[String : Any]] {
                    completion(responseResult, nil, nil)
                } else {
                    let error = NSError(domain: "UnExpectedResponse", code: 500, userInfo: [NSLocalizedDescriptionKey : "Unexpected response received"])
                    completion(response.result.value, nil, error)
                }
            }
            
        case .failure(let error):
            
            if let responseData = response.data, responseData.count > 0 {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String : Any]
                    let serverError = Mapper<ServerError>().map(JSON: jsonObject)
                    serverError?.statusCode = response.response!.statusCode
                    debugPrint("jsonObject: \(jsonObject)")
                    completion(nil, serverError, nil)
                } catch {
                    let genericError = getSomethingWentWrongError(error: error)
                    completion(nil, nil, genericError)
                }
                
            } else if error._code != NSURLErrorCancelled {
                let genericError = getNoInternetError(error: error)
                completion(nil, nil, genericError)
            }
        }
    }
    
    func getNoInternetError(error: Error) -> NSError {
        let genericDesc = "No or weak internet connection"
        let genericError = NSError(domain: error._domain, code: error._code, userInfo: [NSLocalizedDescriptionKey : genericDesc])
        return genericError
    }
    
    func getSomethingWentWrongError(error: Error) -> NSError {
        let genericDesc = genericErrorMessage
        let genericError = NSError(domain: error._domain, code: error._code, userInfo: [NSLocalizedDescriptionKey : genericDesc])
        return genericError
    }
    
    func getGenericError() -> NSError {
        let genericDesc = genericErrorMessage
        let genericError = NSError(domain: "GenericError", code: 400, userInfo: [NSLocalizedDescriptionKey : genericDesc])
        return genericError
    }
    
    func getGenericHeaders() -> [String : String] {
        let headers = ["Accept" : "application/json"]
        return headers
    }
}
