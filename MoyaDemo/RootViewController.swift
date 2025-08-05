//
//  RootViewController.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

class RootViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        // 直接设置stackView，不需要先添加按钮到view
        let stackView = UIStackView(arrangedSubviews: [registerBtn, forgetBtn, loginBtn])
        stackView.axis = .vertical
        stackView.alignment = .fill // 使用.fill替代.top，让按钮充满宽度
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            registerBtn.heightAnchor.constraint(equalToConstant: 44),
            forgetBtn.heightAnchor.constraint(equalToConstant: 44),
            loginBtn.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        bindAction()
    }
    
    private func bindAction() {
        // 注册按钮点击事件
        registerBtn.tapPublisher()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (sender: UIButton) in
                guard let self = self, let navigationController = self.navigationController else { return }
                RegistrationCoordinator(navigationController: navigationController).start()
            }
            .store(in: &cancellables)
        
        // 可以类似地添加登录按钮和忘记密码按钮的点击事件
        loginBtn.tapPublisher()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (sender: UIButton) in
                // 处理登录逻辑
                print("登录按钮点击")
            }
            .store(in: &cancellables)
        
        forgetBtn.tapPublisher()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] (sender: UIButton) in
                guard let self = self, let navigationController = self.navigationController else { return }
                ForgetCoordinator(navigationController: navigationController).start()
            }
            .store(in: &cancellables)
    }
    
    // 按钮属性可以进一步优化，提取共同配置
    private lazy var registerBtn: UIButton = createButton(title: "注册")
    private lazy var loginBtn: UIButton = createButton(title: "登录")
    private lazy var forgetBtn: UIButton = createButton(title: "忘记密码")
    
    // 提取按钮创建的共同逻辑
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .blue
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 8 // 可以添加圆角让按钮更美观
        button.setTitleColor(.white, for: .normal) // 明确设置文字颜色
        return button
    }
}
