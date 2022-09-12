//
//  DeepLinkRouterContract.swift
//  UMA
//
//  Created by Ruchi on 06/07/22.
//

import UIKit

struct RoutingDestination: Equatable {
    var pushSection: String?
    var parameters: [String : String]?
}

//Protocol that need to be inherited in  any new viewcontroller
//created by developer in order to get the new Deep link flow
protocol RoutingProtocol: AnyObject {
    static var routerName: String { get }
    static var routes: [RoutingDestination] { get }
    static func route(to destination: RoutingDestination)
    static func route(to pushSection: String, parameters: [String: String]?)
}


extension RoutingProtocol {
    //This function will fetch the viewcontroller class name against the pushsection key
    //and parameters associated with that pushsection key
   static func getRoutesFromPushsectionMapping() -> [RoutingDestination] {
        var routes = [RoutingDestination]()
        if let pushSectionPlistPath = Bundle.main.path(forResource: DeepLinkConstants.PushSectionMap, ofType: "plist"),
           let pushSectionPlistContents = FileManager.default.contents(atPath: pushSectionPlistPath) {
                if let pushSectionMap = (try? PropertyListSerialization.propertyList(from: pushSectionPlistContents, options: .mutableContainersAndLeaves, format: nil)) as? [String:Any?] {
                    if let pushsectionRouterName = pushSectionMap[routerName] as? [String: Any?] {
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
        return routes.contains(destination)
    }

    //Fuction to get pushsection and parameters values from the routes i.e for the class view controller in plist
    static func getRoutingDestinationFromPushSection(pushSection:String) -> RoutingDestination? {
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
    static func navigateTo(_ viewController: UIViewController?) {
        guard let vc = viewController else { return }
        if let navigationController = UniversalActionController.shared.topVisibleViewController() as? UINavigationController,
           let topVC = navigationController.topViewController {
            navigationController.show(vc, sender: nil)
        }
    }
        
    //Navigate view to home
    static func navigateToViewControllerFromHome(_ viewController: UIViewController?, asModal: Bool) {
        showViewControllerFromHome(viewController, asModal: asModal)
    }
    
    //Present or show destination view
    private static func showViewController(_ controller: UIViewController, asModal: Bool) {
        guard let topView = UniversalActionController.shared.visibleView() else { return }
        if asModal {
            topView.present(controller, animated: true)
        } else {
            topView.show(controller, sender: nil)
        }
    }
    
    //reseting the tab to home first
    //then navigate to destination view
    private static func showViewControllerFromHome(_ controller: UIViewController?, asModal: Bool) {
        guard let homeView = UniversalActionController.shared.getUMAHomeScreen(), let barController = homeView.tabBarController as? DeliveryTabController, let vc = controller else { return }
        resetTabControllerToRoot(tabBarController:barController)
        if asModal {
            vc.modalPresentationStyle = .fullScreen
            homeView.present(vc, animated: true, completion: nil)
        } else {
            homeView.show(vc, sender: nil)
        }
    }

    //Reset to Home tab
    private static func resetTabControllerToRoot(tabBarController: UITabBarController) {
        guard let barController = tabBarController as? DeliveryTabController else { return }
        barController.viewControllers?.forEach {
            let _ = ($0 as? UINavigationController)?.popToRootViewController(animated: false)
        }
        barController.selectedIndex = 0
        barController.selectItem(withIndex: 0)
        if let navController = barController.viewControllers?[0] as? UINavigationController {
            navController.viewControllers.first?.beginAppearanceTransition(true, animated: false)
            navController.dismiss(animated: true)
        }
    }

}
