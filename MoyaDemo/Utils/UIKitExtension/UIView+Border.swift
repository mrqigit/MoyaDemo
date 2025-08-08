//
//  UIView+Border.swift
//  MoyaDemo
//
//  Created by MrQi on 2025/8/6.
//

import UIKit

enum Border: Equatable {
    case none
    case left(color: UIColor = .black, width: CGFloat = 1.0)
    case right(color: UIColor = .black, width: CGFloat = 1.0)
    case top(color: UIColor = .black, width: CGFloat = 1.0)
    case bottom(color: UIColor = .black, width: CGFloat = 1.0)
    case horizontal(color: UIColor = .black, width: CGFloat = 1.0)
    case vertical(color: UIColor = .black, width: CGFloat = 1.0)
    case all(color: UIColor = .black, width: CGFloat = 1.0)
    case custom(
        edges: UIRectEdge,
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    
    /// 获取对应边
    var edges: UIRectEdge {
        switch self {
        case .none:
            return []
        case .left:
            return .left
        case .right:
            return .right
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .horizontal:
            return [.left,.right]
        case .vertical:
            return [.top,.bottom]
        case .all:
            return [.top,.left,.bottom,.right]
        case .custom(let edges, _, _):
            return edges
        }
    }
    
    /// 获取对应颜色
    var color: UIColor {
        switch self {
        case .none:
            return .clear
        case .left(let color, _), 
                .right(let color, _), 
                .top(let color, _), 
                .bottom(let color, _):
            return color
        case .horizontal(let color, _), 
                .vertical(let color, _), 
                .all(let color, _):
            return color
        case .custom(_, let color, _):
            return color
        }
    }
    
    /// 获取宽度
    var width: CGFloat {
        switch self {
        case .none:
            return 0
        case .left(_, let width), 
                .right(_, let width), 
                .top(_, let width), 
                .bottom(_, let width):
            return width
        case .horizontal(_, let width), 
                .vertical(_, let width), 
                .all(_, let width):
            return width
        case .custom(_, _, let width):
            return width
        }
    }
    
    static func == (lhs: Border, rhs: Border) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.left(let lColor, let lWidth), .left(let rColor, let rWidth)):
            return lColor == rColor && lWidth == rWidth
        case (.right(let lColor, let lWidth), .right(let rColor, let rWidth)):
            return lColor == rColor && lWidth == rWidth
        case (.top(let lColor, let lWidth), .top(let rColor, let rWidth)):
            return lColor == rColor && lWidth == rWidth
        case (.bottom(let lColor, let lWidth), .bottom(let rColor, let rWidth)):
            return lColor == rColor && lWidth == rWidth
        case (
            .horizontal(let lColor, let lWidth),
            .horizontal(let rColor, let rWidth)
        ):
            return lColor == rColor && lWidth == rWidth
        case (
            .vertical(let lColor, let lWidth),
            .vertical(let rColor, let rWidth)
        ):
            return lColor == rColor && lWidth == rWidth
        case (.all(let lColor, let lWidth), .all(let rColor, let rWidth)):
            return lColor == rColor && lWidth == rWidth
        case (
            .custom(let lEdges, let lColor, let lWidth),
            .custom(let rEdges, let rColor, let rWidth)
        ):
            return lEdges == rEdges && lColor == rColor && lWidth == rWidth
        default:
            return false
        }
    }
}

// 虚线边框枚举，支持不同方向和样式的虚线
enum DashBorder: Equatable {
    case none
    case left(pattern: [CGFloat], color: UIColor = .black, width: CGFloat = 1.0)
    case right(
        pattern: [CGFloat],
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    case top(pattern: [CGFloat], color: UIColor = .black, width: CGFloat = 1.0)
    case bottom(
        pattern: [CGFloat],
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    case horizontal(
        pattern: [CGFloat],
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    case vertical(
        pattern: [CGFloat],
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    case all(pattern: [CGFloat], color: UIColor = .black, width: CGFloat = 1.0)
    case custom(
        edges: UIRectEdge,
        pattern: [CGFloat],
        color: UIColor = .black,
        width: CGFloat = 1.0
    )
    
    // 虚线样式，数组中元素交替表示实线长度和空白长度
    var dashPattern: [CGFloat] {
        switch self {
        case .none: return []
        case .left(let pattern, _, _), 
                .right(let pattern, _, _), 
                .top(let pattern, _, _), 
                .bottom(let pattern, _, _):
            return pattern
        case .horizontal(let pattern, _, _), 
                .vertical(let pattern, _, _), 
                .all(let pattern, _, _):
            return pattern
        case .custom(_, let pattern, _, _):
            return pattern
        }
    }
    
    // 获取对应的边
    var edges: UIRectEdge {
        switch self {
        case .none: return []
        case .left: return .left
        case .right: return .right
        case .top: return .top
        case .bottom: return .bottom
        case .horizontal: return [.top, .bottom]
        case .vertical: return [.left, .right]
        case .all: return [.top, .left, .bottom, .right]
        case .custom(let edges, _, _, _): return edges
        }
    }
    
    // 获取颜色
    var color: UIColor {
        switch self {
        case .none: return .clear
        case .left(_, let color, _), 
                .right(_, let color, _), 
                .top(_, let color, _), 
                .bottom(_, let color, _):
            return color
        case .horizontal(_, let color, _), 
                .vertical(_, let color, _), 
                .all(_, let color, _):
            return color
        case .custom(_, _, let color, _):
            return color
        }
    }
    
    // 获取宽度
    var width: CGFloat {
        switch self {
        case .none: return 0
        case .left(_, _, let width), 
                .right(_, _, let width), 
                .top(_, _, let width), 
                .bottom(_, _, let width):
            return width
        case .horizontal(_, _, let width), 
                .vertical(_, _, let width), 
                .all(_, _, let width):
            return width
        case .custom(_, _, _, let width):
            return width
        }
    }
    
    // 手动实现相等性检查
    static func == (lhs: DashBorder, rhs: DashBorder) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (
            .left(let lPattern, let lColor, let lWidth),
            .left(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .right(let lPattern, let lColor, let lWidth),
            .right(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .top(let lPattern, let lColor, let lWidth),
            .top(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .bottom(let lPattern, let lColor, let lWidth),
            .bottom(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .horizontal(let lPattern, let lColor, let lWidth),
            .horizontal(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .vertical(let lPattern, let lColor, let lWidth),
            .vertical(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .all(let lPattern, let lColor, let lWidth),
            .all(let rPattern, let rColor, let rWidth)
        ):
            return lPattern == rPattern && lColor == rColor && lWidth == rWidth
        case (
            .custom(let lEdges, let lPattern, let lColor, let lWidth),
            .custom(let rEdges, let rPattern, let rColor, let rWidth)
        ):
            return lEdges == rEdges && lPattern == rPattern && lColor == rColor && lWidth == rWidth
        default:
            return false
        }
    }
}

extension UIView {
    
    // 存储当前边框样式，用于边界变化时更新
    private var currentBorder: Border? {
        get {
            return objc_getAssociatedObject(
                self,
                &AssociatedKeys.currentBorder
            ) as? Border
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.currentBorder,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    // 存储是否已添加观察者的标记
    private var hasAddedBorderObserver: Bool {
        get {
            return (
                objc_getAssociatedObject(
                    self,
                    &AssociatedKeys.hasAddedBorderObserver
                ) as? Bool
            ) ?? false
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.hasAddedBorderObserver,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN
            )
        }
    }
    
    // 存储当前虚线边框样式
    private var currentDashBorder: DashBorder? {
        get {
            return objc_getAssociatedObject(
                self,
                &AssociatedKeys.currentDashBorder
            ) as? DashBorder
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.currentDashBorder,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
        
    // 存储是否已添加虚线边框观察者
    private var hasAddedDashBorderObserver: Bool {
        get {
            return (
                objc_getAssociatedObject(
                    self,
                    &AssociatedKeys.hasAddedDashBorderObserver
                ) as? Bool
            ) ?? false
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.hasAddedDashBorderObserver,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN
            )
        }
    }
    
    private struct AssociatedKeys {
        static var currentBorder: UInt8 = 0
        static var hasAddedBorderObserver: UInt8 = 0
        static var currentDashBorder: UInt8 = 0
        static var hasAddedDashBorderObserver: UInt8 = 0
    }
    
    private var borderLayerName: String { "border_layer_10086" }
    private var dashLayerName: String { "dash_border_layer_10086" }
    
    /// 添加边框
    func applyBorder(border: Border) {
        removeLayer(with: borderLayerName)
        
        guard border != .none, border.width > 0 else {
            // 如果是无虚线边框，且已添加观察者，则移除
            if hasAddedDashBorderObserver {
                removeObserver(
                    self,
                    forKeyPath: "bounds",
                    context: &AssociatedKeys.currentBorder
                )
                hasAddedBorderObserver = false
            }
            return
        }
        
        let color = border.color
        let width = border.width
        let edges = border.edges
                
        let borderLayer = CAShapeLayer()
        borderLayer.name = borderLayerName
        borderLayer.strokeColor = color.cgColor
        borderLayer.fillColor = nil
        borderLayer.lineWidth = width
                
        let path = UIBezierPath()
//        let rect = bounds.insetBy(dx: width/2, dy: width/2)
                
        if edges.contains(.top) {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        }
                
        if edges.contains(.left) {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: bounds.size.height))
        }
                
        if edges.contains(.bottom) {
            path.move(to: CGPoint(x: 0, y: bounds.size.height))
            path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        }
                
        if edges.contains(.right) {
            path.move(to: CGPoint(x: bounds.size.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        }
                
        borderLayer.path = path.cgPath
        layer.addSublayer(borderLayer)
                
        // 监听视图边界变化，更新边框
        layer.masksToBounds = true
        
        if !hasAddedBorderObserver {
            addObserver(
                self,
                forKeyPath: "bounds",
                options: .new,
                context: &AssociatedKeys.currentBorder
            )
        }
    }
    
    // 应用虚线边框
    func applyDashBorder(dashBorder: DashBorder) {
        // 先移除已有的虚线边框层
        removeLayer(with: dashLayerName)
            
        currentDashBorder = dashBorder
            
        guard dashBorder != .none, dashBorder.width > 0, !dashBorder.dashPattern.isEmpty else {
            // 如果是无虚线边框，且已添加观察者，则移除
            if hasAddedDashBorderObserver {
                removeObserver(
                    self,
                    forKeyPath: "bounds",
                    context: &AssociatedKeys.currentDashBorder
                )
                hasAddedDashBorderObserver = false
            }
            return
        }
            
        let color = dashBorder.color
        let width = dashBorder.width
        let edges = dashBorder.edges
        let pattern = dashBorder.dashPattern
            
        let borderLayer = CAShapeLayer()
        borderLayer.name = "dash_border_layer"
        borderLayer.strokeColor = color.cgColor
        borderLayer.fillColor = nil
        borderLayer.lineWidth = width
        borderLayer.lineDashPattern = pattern
            .map { NSNumber(value: Double($0)) }
            
        let path = UIBezierPath()
        let rect = bounds.insetBy(dx: width/2, dy: width/2)
            
        if edges.contains(.top) {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
            
        if edges.contains(.left) {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
            
        if edges.contains(.bottom) {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
            
        if edges.contains(.right) {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
            
        borderLayer.path = path.cgPath
        layer.addSublayer(borderLayer)
            
        // 监听视图边界变化，更新虚线边框
        layer.masksToBounds = true
            
        // 确保只添加一次观察者
        if !hasAddedDashBorderObserver {
            addObserver(
                self,
                forKeyPath: "bounds",
                options: .new,
                context: &AssociatedKeys.currentDashBorder
            )
            hasAddedDashBorderObserver = true
        }
    }
    
    /// 移除现有指定Layer
    func removeLayer(with name: String) {
        layer.sublayers?
            .filter { $0.name == name }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "bounds", context == &AssociatedKeys.currentBorder, let currentBorder = currentBorder {
            applyBorder(border: currentBorder)
        } else if keyPath == "bounds", context == &AssociatedKeys.currentDashBorder, let currentDashBorder = currentDashBorder {
            applyDashBorder(dashBorder: currentDashBorder)
        }
    }
    
    func cleanupBorderObserving() {
        if hasAddedBorderObserver {
            removeObserver(
                self,
                forKeyPath: "bounds",
                context: &AssociatedKeys.currentBorder
            )
            hasAddedBorderObserver = false
        }
        
        if hasAddedDashBorderObserver {
            removeObserver(
                self,
                forKeyPath: "bounds",
                context: &AssociatedKeys.currentDashBorder
            )
            hasAddedDashBorderObserver = false
        }
    }
}
