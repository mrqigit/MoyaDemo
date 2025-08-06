//
//  LoginViewController.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/5.
//

import UIKit
import SnapKit

class LoginViewController: BaseViewController<LoginViewModel> {
    
    lazy var topBgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "login_bg")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "验证码登录"
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        let username = "AliGator"
        let str: AttrString = """
          \("还没账号，", .font(.systemFont(ofSize: 14, weight: .medium)), .color(.init(hexString: "#989FA8")))\("立即注册", .font(.systemFont(ofSize: 14, weight: .medium)), .color(.init(hexString: "#E12F3D")))
          """
        label.attributedText = str.attributedString
        return label
    }()
    
    lazy var mobileTF: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        let str: AttrString = """
\("请输入手机号", .font(.systemFont(ofSize: 17, weight: .medium)), .color(.init(hexString: "#989FA8")))
"""
        textField.attributedPlaceholder = str.attributedString
        textField.addDynamicPadding(padding: .symmetric(horizontal: 30, vertical: 15))
        textField.applyBorder(border: .bottom(color: .init(hexString: "#E4E7ED"), width: 1))
        return textField
    }()
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(topBgView)
        
        topBgView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(228)
        }
        
        topBgView.addSubview(titleLabel)
        topBgView.addSubview(tipLabel)
        
        tipLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-46)
            make.left.right.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(tipLabel.snp_topMargin).offset(-10)
            make.left.right.equalTo(50)
        }
        
        view.addSubview(mobileTF)
        mobileTF.snp.makeConstraints { make in
            make.left.right.equalTo(30)
            make.top.equalTo(topBgView.snp_bottomMargin).offset(18)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        // 订阅点击事件
        titleLabel.tapPublisher()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                guard let navigationController = self.navigationController else { return }
                RegistrationCoordinator(navigationController: navigationController).start()
            })
            .store(in: &viewCancellables)
    }
}

extension LoginViewController {
    
}
