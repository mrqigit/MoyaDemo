//
//  ForgetCoordinator.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine

// 定义注册流程的导航事件
enum ForgetNavigationEvent {
    case foretCompletion
    case cancel
}

class ForgetCoordinator: NSObject, Coordinators {
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var parentCoordinator: (any Coordinators)?
    
    var children: [any Coordinators] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    func start() {
        let viewModel = ForgotViewModel()
        viewModel.navigationEvent.sink { [weak self] (event) in
            guard let self = self else { return }
            switch event {
            case .foretCompletion:
                self.parentCoordinator?.childDidFinish(self)
            case .cancel:
                self.parentCoordinator?.childDidFinish(self)
            }
        }.store(in: &cancellables)
        navigationController.pushViewController(ForgotPasswordViewController(viewModel: viewModel), animated: true)
    }
}

extension ForgetCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        
        guard let fromViewController = kg_navigationController(navigationController, didShow: viewController, animated: animated) else { return }
        
        // 如果前一个控制器是我们的注册控制器，说明已经返回，结束当前协调器
        if fromViewController is RegistrationViewController {
            parentCoordinator?.childDidFinish(self)
        }
    }
}
