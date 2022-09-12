//
//  DeepLinkMasterRouter.swift
//  UMA
//
//  Created by Ruchi on 06/07/22.
//

import Foundation
import UIKit

class DeepLinkMasterRouter {
    static let shared = DeepLinkMasterRouter()
    // This function will get called from DeepLink Handler Class when there is valid pushSection in plist file
    func route(to pushSection: String, parameters:[String:String]? = nil)  {
        if let router = checkValidRouteAndGetRouter(pushSection: pushSection),
           var routingDestination = router.getRoutingDestinationFromPushSection(pushSection: pushSection) {
            
            if let params = parameters {
                for (parameter, value) in params {
                    if let _ = routingDestination.parameters?[parameter] {
                        routingDestination.parameters?[parameter] = value
                    }
                }
            }
            //This will redirect to viewcontroller class, which inherits the RoutingProtocol
            router.route(to: routingDestination)
        }
    }

    //This function will return a viewcontroller class name against the  key(pushsection value) in plist.
    func checkValidRouteAndGetRouter(pushSection: String) -> RoutingProtocol.Type? {
        if let routeName = getRouterNameFromPlist(pushSection: pushSection) {
            return getDeepLinkingRouterFromClassname(className: routeName)
        }
        return nil
    }
    
    //This function will return a viewcontroller class name
    //if Destination Router known (i.e. invoking one screen to another)
    func checkValidRouteAndGetRouter(routingDestination: RoutingDestination) -> RoutingProtocol.Type? {
        if let destination = routingDestination.pushSection, let routeName = getRouterNameFromPlist(pushSection: destination) {
            return getDeepLinkingRouterFromClassname(className: routeName)
        }
        return nil
    }
    
    //This function fetch the plist file from Bundle Path
    //Fetch the Dictionary with pushsection name and viwecontroller class name
    //Fetch the parameters if the pushsection have associated parameters
    private func getRouterNameFromPlist(pushSection: String) -> String? {
        if let pushSectionPlistPath = Bundle.main.path(forResource: DeepLinkConstants.PushSectionMap, ofType: "plist"),
           let pushSectionPlistContents = FileManager.default.contents(atPath: pushSectionPlistPath) {
            if let pushSectionMap = (try? PropertyListSerialization.propertyList(from: pushSectionPlistContents, options: .mutableContainersAndLeaves, format: nil)) as? [String:Any?] {
                for (_, value) in pushSectionMap {
                    if let parameters = value as? [String:Any], let mappedParameters = parameters[pushSection] {
                        if let directMappingToClassName = mappedParameters as? String{
                            return directMappingToClassName
                        } else if let parametersMappingToClassName = mappedParameters as? [String:Any]{
                            return parametersMappingToClassName[DeepLinkConstants.ClassName] as? String
                        }
                        
                    }
                }
                return ""
            }
        }
        return nil
    }
    //This function return a class name from app Bundle and return it as a routing protocol type
    // Routing protocold defines in DeepLinkRouterContract as :-
    //    protocol RoutingProtocol: AnyObject {
    //        static var routerName: String { get }
    //        static var routes: [RoutingDestination] { get }
    //        static func route(to destination: RoutingDestination)
    //        static func route(to pushSection: String, parameters: [String: String]?)
    //    }
    private func getDeepLinkingRouterFromClassname(className: String) -> RoutingProtocol.Type? {
        if let moduleName = Bundle.main.infoDictionary!["CFBundleName"] as? String,
           let routingProtocolType = NSClassFromString("\(moduleName).\(className)") as? RoutingProtocol.Type {
            return routingProtocolType
        }
        return nil
    }
}

// MARK: Check for invalid Push Sections
extension DeepLinkMasterRouter {    
    func routeToPageIfValidPushSection(pushSection: String, parameters: [AnyHashable : Any]? =  nil ) {
        let deepLinkingHandler = DeepLinkingHandler.sharedInstance
        if let _ = checkValidRouteAndGetRouter(pushSection: pushSection.lowercased()) {
            deepLinkingHandler.delegate?.handlePushsection(pushSection: pushSection.lowercased(), parameters: parameters )
        } else {
            CommonUtils.showUpdateAlertForInvalidPushSection(title: ConstantTitle.updateAppTitle, message: ConstantTitle.appStoreMessage)
        }
    }
    
}
