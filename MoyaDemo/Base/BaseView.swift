//
//  BaseView.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/1.
//

import UIKit

protocol BaseView: AnyObject {
    associatedtype ViewModelType: BaseViewModel
    
    var viewModel: ViewModelType { get }
    
    func setupUI()
    
    func setupLayout()
    
    func bindViewModel()
}
