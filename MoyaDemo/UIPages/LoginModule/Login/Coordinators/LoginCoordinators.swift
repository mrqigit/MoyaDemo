//
//  LoginCoordinators.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit

class LoginCoordinators: NSObject, Coordinators {
    var parentCoordinator: Coordinators?
    
    var children: [Coordinators] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    func start() {
        
    }
}

extension LoginCoordinators: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = kg_navigationController(navigationController, didShow: viewController, animated: animated) else {
            return
        }
        // 如果前一个控制器是我们的注册控制器，说明已经返回，结束当前协调器
        if fromViewController is LoginViewController {
            parentCoordinator?.childDidFinish(self)
        }
    }
}
