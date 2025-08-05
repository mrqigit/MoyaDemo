//
//  Coordinators.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit

protocol Coordinators: AnyObject {
    
    var parentCoordinator: Coordinators? { get set }
    var children: [Coordinators] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinators {
    func childDidFinish(_ child: Coordinators) {
        if let index = children.firstIndex(where: { $0 === child }) {
            children.remove(at: index)
        }
    }
    
    func kg_navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) -> UIViewController? {
        
        // 确认前一个控制器是否存在
        guard let fromViewController = navigationController.transitionCoordinator?
            .viewController(forKey: .from) else { return nil }
        
        // 检查是否已经展示过当前控制器
        if navigationController.viewControllers.contains(fromViewController) {
            return nil
        }
        
        return fromViewController
    }
}
