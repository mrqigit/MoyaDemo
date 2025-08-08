//
//  LoginCoordinators.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine

enum LoginNavigationEvent {
    case loginCompletion
    case register
    case passLogin
    case verificationLogin
    case forgetPassword
    case protocolRead
    case cancel
}

class LoginCoordinators: NSObject, Coordinators {
    var cancellables: Set<AnyCancellable> = []
    
    weak var parentCoordinator: Coordinators? = nil
    
    var children: [Coordinators] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }
    
    func start() {
        let viewModel = LoginViewModel()
        navigationController
            .pushViewController(
                LoginViewController(viewModel: viewModel),
                animated: true
            )
        
        viewModel.navigationEvent.sink { [weak self] (event) in
            guard let self = self else { return }
            switch event {
            case .loginCompletion:
                self.parentCoordinator?.childDidFinish(self)
            case .register:
                let register = RegistrationCoordinator(
                    navigationController: self.navigationController
                )
                addChild(register)
                register.start()
            case .passLogin:
                print("\(event.self)")
            case .verificationLogin:
                print("\(event.self)")
            case .forgetPassword:
                let forget = ForgetCoordinator(
                    navigationController: self.navigationController
                )
                addChild(forget)
                forget.start()
            case .protocolRead:
                print("\(event.self)")
            case .cancel:
                self.parentCoordinator?.childDidFinish(self)
            }
        }.store(in: &cancellables)
    }
}

extension LoginCoordinators: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromViewController = kg_navigationController(navigationController, didShow: viewController, animated: animated) else {
            return
        }
        // 如果前一个控制器是我们的注册控制器，说明已经返回，结束当前协调器
        if fromViewController is LoginViewController {
            parentCoordinator?.childDidFinish(self)
        }
    }
}
