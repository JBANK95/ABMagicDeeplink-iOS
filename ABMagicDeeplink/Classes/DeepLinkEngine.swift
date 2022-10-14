//
//  DeepLinkEngine.swift
//  ABMagicDeeplink
//
//  Created by John Banks on 9/19/22.
//

import Foundation

public protocol MagicNavigation: AnyObject {
    func magicNavigateTo(toVc:UIViewController)
    func magicNavigateToFromHome(controller: UIViewController?, asModal: Bool)
    func magicGetClassFromApp(className: String) -> RoutingProtocol.Type?
}

public class DeepLinkEngine {
    
    public static let shared = DeepLinkEngine()
    var routesFromPlist: NSMutableDictionary?
    var magicNavigation: MagicNavigation?
    var moduleName: String?
    
    public func activate(navigation:MagicNavigation, routes: NSMutableDictionary){
        magicNavigation = navigation
        routesFromPlist = routes
    }

}
