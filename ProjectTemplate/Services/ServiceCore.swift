//
//  ServiceCore.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 08/11/2022.
//

import Foundation
import Moya
import Alamofire
import ProgressHUD

enum NetworkError: Error {
    case objectMapping
    case httpCodeNotValid
}

class ProgressHUDCenter {
    static let shared = ProgressHUDCenter()
    var trackingIndicator: Int = 0 {
        didSet {
            if trackingIndicator > 0 {
                ProgressHUD.show(interaction: false)
            } else {
               ProgressHUD.dismiss()
            }
        }
    }
    
    private init() {
        ProgressHUD.colorBackground = UIColor.black.withAlphaComponent(0.5)
    }
}

final class ServiceCore {
    
    static let shared = ServiceCore()
    
    func debugLog(response: Response)  {
        debugPrint("---------------------------------------------------------------")
        debugPrint("==RESPONSE")
        debugPrint(response.response ?? "")
        do {
            let parsedJson = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments)
            let dataJson = try JSONSerialization.data(withJSONObject: parsedJson, options: .prettyPrinted)
            if let string = NSString(data: dataJson, encoding: String.Encoding.utf8.rawValue) {
                debugPrint(string)
            }
        } catch let error {
            debugPrint(error)
        }
        debugPrint ("--------------------------------END-------------------------------")
        //#endif
    }
    
    func debugLogRequest(_ url: String, param: [String: Any]?, method: HTTPMethod) {
        //#if DEBUG
        debugPrint("--------------------------------START-------------------------------")
        debugPrint("==URL: \(url)")
        debugPrint("==Method: \(method)")
        debugPrint("==PARAMS: ", param as AnyObject)
        debugPrint("---------------------------------------------------------------")
        //#endif
    }
    
    func request<D: Decodable, T: TargetType>(_ type: D.Type,
                                              targetType: T,
                                              isShowHUD: Bool = true,
                                              successBlock: @escaping ((D)->Void),
                                              failureBlock: @escaping ((MoyaError)->Void)) {
        let provider = MoyaProvider<T>()
        provider.session.sessionConfiguration.timeoutIntervalForRequest = 10
        provider.session.sessionConfiguration.urlCache = nil
        provider.request(targetType, completion: { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                ProgressHUDCenter.shared.trackingIndicator -= 1
                self.debugLog(response: response)
                if response.statusCode == 200 {
                    let data = response.data
//                    data.tranforms1(to: D.self)
                    if let responseModel = data.tranforms(to: D.self) {
                        successBlock(responseModel)
                    } else {
                        failureBlock(MoyaError.objectMapping(NetworkError.objectMapping, response))
                    }
                } else {
                    failureBlock(MoyaError.statusCode(response))
                }
            case .failure(let error):
                ProgressHUDCenter.shared.trackingIndicator -= 1
                failureBlock(error)
                debugPrint(error.errorDescription.isNil(value: ""))
            }
        })
        if isShowHUD {
            ProgressHUDCenter.shared.trackingIndicator += 1
        }
    }
}
