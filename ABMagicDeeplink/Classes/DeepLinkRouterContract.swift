//
//  DeepLinkRouterContract.swift
//  UMA
//
//  Created by Ruchi on 06/07/22.
//

import UIKit

public protocol MagicDeepLinkRoutingContract : AnyObject{
    func getModuleDeepLinkRoutes() -> NSMutableDictionary
}

public struct RoutingDestination: Equatable {
    public var pushSection: String?
    public var parameters: [String : String]?
}


//Protocol that need to be inherited in  any new viewcontroller
//created by developer in order to get the new Deep link flow
public protocol RoutingProtocol: AnyObject {
    static var routerName: String { get }
    static func route(to destination: RoutingDestination)
}

extension RoutingProtocol {
    
    //This function will fetch the viewcontroller class name against the pushsection key
    //and parameters associated with that pushsection key
   public static func getRoutesFromPushsectionMapping() -> [RoutingDestination] {
        var routes = [RoutingDestination]()
        
        if let pushSectionMap = DeepLinkEngine.shared.routesFromPlist,
           let pushsectionRouterName = pushSectionMap[routerName] as? [String: Any?] {
                
                for (key,value) in pushsectionRouterName {
                    if let parameters = value as? [String:String?]{ //Route with defined parameters
                        var deepLinkParameters = [String:String]()
                        for (parameterName, _) in parameters {
                            if parameterName != DeepLinkConstants.ClassName {
                                deepLinkParameters[parameterName] = ""
                            }
                        }
                        routes.append(RoutingDestination.init(pushSection: key, parameters: deepLinkParameters))
                    } else if let _ = value as? String { // Route without parameters just the ClassName mapping
                        routes.append(RoutingDestination.init(pushSection: key, parameters: nil))
                    }
                }
            
                return routes
            }
                
       return []
    }
    
    //Additional method which can be used further in any class function or deliveryTabController
    //to route to particiular viewcontroller i.e destination
    // Destination Router known (i.e. invoking one screen to another)
    static func validateRoute(to destination: RoutingDestination) -> Bool {
        let routes = getRoutesFromPushsectionMapping()
        return routes.contains(destination)
    }

    //Function to get pushsection and parameters values from the routes i.e for the class view controller in plist
    static func getRoutingDestinationFromPushSection(pushSection:String) -> RoutingDestination? {
        let routes = getRoutesFromPushsectionMapping()
        return routes.first(where: { element in
            element.pushSection == pushSection
        })
    }
    
    //This function need to be called in implementting view controller class
    //which will route to the detination view
    static func route(to pushSection: String, parameters:[String:String]? = nil) {
        route(to: RoutingDestination.init(pushSection: pushSection, parameters: parameters))
    }
    
    // MARK: - Functions implements the navigation
    public static func navigateTo(_ viewController: UIViewController?) {
        guard let vc = viewController,
              let magicNavigation = DeepLinkEngine.shared.magicNavigation else { return }
        magicNavigation.magicNavigateTo(toVc: vc)
    }
        
    //Navigate view to home
    public static func navigateToViewControllerFromHome(_ viewController: UIViewController?, asModal: Bool) {
        guard let vc = viewController,
              let magicNavigation = DeepLinkEngine.shared.magicNavigation else { return }
        magicNavigation.magicNavigateToFromHome(controller: viewController, asModal: asModal)
    }
}
