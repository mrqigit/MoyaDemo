//
//  RegistrationViewController.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

class RegistrationViewController: BaseViewController<RegistrationViewModel> {
    // 输入控件
    private let usernameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    // 设置UI
    override func setupUI() {
        
        super.setupUI()
        
        title = "用户注册"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        
        // 配置文本输入框
        configureTextField(usernameTextField, placeholder: "请输入用户名")
        configureTextField(emailTextField, placeholder: "请输入邮箱地址", keyboardType: .emailAddress)
        configureTextField(passwordTextField, placeholder: "请输入密码", isSecure: true)
        configureTextField(confirmPasswordTextField, placeholder: "请确认密码", isSecure: true)
        
        // 配置注册按钮
        registerButton.setTitle("注册", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registerButton)
        
        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped)
        
        // 布局输入框
        setupInputFieldsLayout()
    }
    
    // 配置文本输入框
    private func configureTextField(_ textField: UITextField, placeholder: String,
                                   keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
    }
    
    // 设置输入框布局
    private func setupInputFieldsLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            usernameTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // 绑定视图模型
    override func bindViewModel() {
        super.bindViewModel()
        
        // 绑定文本输入到ViewModel
        usernameTextField.textPublisher
            .assign(to: &viewModel.$userName)
        
        emailTextField.textPublisher
            .assign(to: &viewModel.$email)
        
        passwordTextField.textPublisher
            .assign(to: &viewModel.$password)
        
        confirmPasswordTextField.textPublisher
            .assign(to: &viewModel.$confirmPass)
        
        // 绑定注册按钮状态
        viewModel.$isRegisterButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.registerButton.isEnabled = isEnabled
                self?.registerButton.alpha = isEnabled ? 1.0 : 0.5
            }
            .store(in: &viewCancellables)
        
        // 绑定注册结果
        viewModel.$registationResponse
            .compactMap { $0 }
            .sink { [weak self] response in
                if response.success, let message = response.message {
                    self?.showAlert(title: "注册成功", message: message)
                }
            }
            .store(in: &viewCancellables)
    }
    
    // 注册按钮点击事件
    @objc private func registerTapped() {
        view.endEditing(true) // 收起键盘
        viewModel.preformRegistration()
    }
    
    // 取消按钮点击事件
    @objc private func cancelTapped() {
        viewModel.cancelRegistration()
    }
    
    // 重写弹窗方法
    override func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// UITextField扩展，提供Combine支持
extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { $0.object as? UITextField }
        .map { $0.text ?? "" }
        .eraseToAnyPublisher()
    }
}
