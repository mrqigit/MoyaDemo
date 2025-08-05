//
//  ForgetViewController.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import Combine

class ForgotPasswordViewController: BaseViewController<ForgotViewModel> {
    // 视图组件
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let verificationCodeTextField = UITextField()
    private let newPasswordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let nextButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // 订阅管理
    private var cancellables = Set<AnyCancellable>()
    
    // 初始化
    init(
        viewModel: ForgotViewModel = ForgotViewModel()
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // 设置UI
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, emailTextField, verificationCodeTextField, newPasswordTextField, confirmPasswordTextField, nextButton, backButton, errorLabel, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 标题
        titleLabel.text = "忘记密码"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        // 文本框配置
        emailTextField.placeholder = "请输入注册邮箱"
        emailTextField.keyboardType = .emailAddress
        emailTextField.borderStyle = .roundedRect
        emailTextField.delegate = self
        
        verificationCodeTextField.placeholder = "请输入验证码"
        verificationCodeTextField.keyboardType = .numberPad
        verificationCodeTextField.borderStyle = .roundedRect
        verificationCodeTextField.delegate = self
        
        newPasswordTextField.placeholder = "请设置新密码"
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.delegate = self
        
        confirmPasswordTextField.placeholder = "请确认新密码"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.delegate = self
        
        // 按钮配置
        nextButton.setTitle("下一步", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        nextButton
            .addTarget(
                self,
                action: #selector(nextButtonTapped),
                for: .touchUpInside
            )
        nextButton.isEnabled = false
        
        backButton.setTitle("返回", for: .normal)
        backButton
            .addTarget(
                self,
                action: #selector(backButtonTapped),
                for: .touchUpInside
            )
        
        // 错误标签
        errorLabel.textColor = .red
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        // 加载指示器
        activityIndicator.hidesWhenStopped = true
        
        // 布局
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            emailTextField,
            verificationCodeTextField,
            newPasswordTextField,
            confirmPasswordTextField,
            errorLabel,
            nextButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(backButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate(
            [
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor, constant: 40),
                stackView.trailingAnchor
                    .constraint(equalTo: view.trailingAnchor, constant: -40),
            
                backButton.topAnchor
                    .constraint(
                        equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: 16
                    ),
                backButton.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor, constant: 16),
            
                activityIndicator.centerXAnchor
                    .constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor
                    .constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    // 绑定ViewModel
    private func bindViewModel() {
        
        emailTextField.textPublisher.assign(to: &viewModel.$email)
        verificationCodeTextField.textPublisher
            .assign(to: &viewModel.$verificationCode)
        newPasswordTextField.textPublisher.assign(to: &viewModel.$newPassword)
        confirmPasswordTextField.textPublisher
            .assign(to: &viewModel.$confirmPassword)
        
        // 步骤变化
        viewModel.currentStep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] step in
                DispatchQueue.main.async {
                    self?.updateUI(for: step)
                }
            }.store(in: &cancellables)
        
        // 按钮绑定状态
        Publishers
            .CombineLatest4(
                viewModel.currentStep,
                viewModel.isEmailValid,
                viewModel.isVerificationCodeValid,
                viewModel.isPasswordValid
            )
            .receive(on: DispatchQueue.main)
            .map { step, emailValid, verificationValid, passValid in
                switch step {
                case .enterEmail: return emailValid
                case .enterVerificationCode: return verificationValid
                case .setNewPassword: return passValid
                }
            }.assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
        
        // 错误信息
        viewModel.$errorMessage.receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                DispatchQueue.main.async {
                    self?.errorLabel.text = message
                    self?.errorLabel.isHidden = message == nil
                }
            }.store(in: &cancellables)
        
        // 加载状态
        viewModel.$isLoading.receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                DispatchQueue.main.async {
                    isLoading ? self?.activityIndicator
                        .startAnimating() : self?.activityIndicator
                        .stopAnimating()
                    self?.view.isUserInteractionEnabled = !isLoading
                }
            }.store(in: &cancellables)
        
        // 邮箱验证状态
        viewModel.resetSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                DispatchQueue.main.async {
                    self?.showSuccessAlert()
                }
            }.store(in: &cancellables)
    }
    
    // 更新UI以匹配当前步骤
    private func updateUI(for step: ResetPasswordStep) {
        emailTextField.isHidden = step != .enterEmail
        verificationCodeTextField.isHidden = step != .enterVerificationCode
        newPasswordTextField.isHidden = step != .setNewPassword
        confirmPasswordTextField.isHidden = step != .setNewPassword
        
        switch step {
        case .enterEmail:
            nextButton.setTitle("发送验证码", for: .normal)
            backButton.isHidden = true
        case .enterVerificationCode:
            nextButton.setTitle("验证并继续", for: .normal)
            backButton.isHidden = false
        case .setNewPassword:
            nextButton.setTitle("重置密码", for: .normal)
            backButton.isHidden = false
        }
        
        // 重置按钮状态
        nextButton.isEnabled = false
    }
    
    // 下一步按钮点击
    @objc private func nextButtonTapped() {
        view.endEditing(true)
        
        viewModel.nextTap()
    }
    
    // 返回按钮点击
    @objc private func backButtonTapped() {
        viewModel.goBack()
    }
    
    // 显示成功提示
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "成功",
            message: "密码已成功重置，请使用新密码登录",
            preferredStyle: .alert
        )
        alert
            .addAction(
                UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// 扩展用于处理文本输入
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        switch textField {
        case emailTextField:
            viewModel.email = newText
        case verificationCodeTextField:
            viewModel.verificationCode = newText
        case newPasswordTextField:
            viewModel.newPassword = newText
        case confirmPasswordTextField:
            viewModel.confirmPassword = newText
        default:
            break
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
