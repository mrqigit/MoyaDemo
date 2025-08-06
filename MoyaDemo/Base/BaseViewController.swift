//
//  BaseViewController.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit
import Combine

class BaseViewController<VM: BaseViewModel>: UIViewController, BaseView {
    
    typealias ViewModelType = VM
    
    let viewModel: VM
    
    // 加载指示器
    public let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // 存储视图相关的订阅
    public var viewCancellables = Set<AnyCancellable>()
    
    // 错误处理
    private var errorCancellable: AnyCancellable?
    
    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    private func setupBaseUI() {
        view.backgroundColor = .white
        
        // 配置加载器
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    // 基础布局设置
    private func setupBaseLayout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // 绑定基础ViewModel状态
    private func bindBaseViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.activityIndicator.startAnimating()
                default:
                    self.activityIndicator.stopAnimating()
                }
            }
            .store(in: &viewCancellables)
        
        viewModel.$alertMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(title: "错误", message: message)
            }.store(in: &viewCancellables)
    }
    
    // 显示弹窗的通用方法
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // 子类需要实现的方法
    func setupUI() {
        setupBaseUI()
    }
    
    func setupLayout() {
        setupBaseLayout()
    }
    
    func bindViewModel() {
        bindBaseViewModel()
    }
}
