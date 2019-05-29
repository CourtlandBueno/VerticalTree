//
//  VerticalTreeIndexView.swift
//  VerticalTreeIndexView
//
//  Created by Daniel Yang on 2019/1/18.
//  Copyright © 2019 Daniel Yang. All rights reserved.
//

#if os(iOS)
import UIKit

open class VerticalTreeIndexView<T: VerticalTreeNode>: UIView {
    weak var listController: VerticalTreeListController<T>?
    open var labelLeading: NSLayoutConstraint?
    
    open lazy var label: UILabel = {
        let _label = UILabel()
        _label.textColor = UIColor.darkText
        _label.font = UIFont.preferredFont(forTextStyle: .body)
        _label.adjustsFontForContentSizeCategory = true
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    
    var horizonLine = CALayer()
    var verticalLines = [CALayer]()
    
    public var node: T? {
        didSet {
            guard let node = node else { return }
            
            let treeDeep = node.treeDeep
            let nodeDeep = node.currentDeep
            label.text = node.info.nodeTitle
            label.textColor = (node.info.nodeDescription ?? "").isEmpty ? UIColor.red : UIColor.treeDeep(nodeDeep, treeDeep)
            horizonLine.backgroundColor = UIColor.treeDeep(nodeDeep, treeDeep).cgColor
            
            verticalLines.flexibleReuse(targetCount: node.currentDeep+1, map: { () -> CALayer in
                let layer = CALayer()
                self.layer.addSublayer(layer)
                return layer
            }, handle: {
                $0.removeFromSuperlayer()
            })
            verticalLines.enumerated().forEach { $1.backgroundColor = UIColor.treeDeep($0, treeDeep).cgColor }
            labelLeading?.constant = indexLeading + 4
            self.setNeedsLayout()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentView()
        setupGestureRecognizers()
    }
    
    open func setupContentView() {
        addSubview(label)
        layer.addSublayer(horizonLine)
        
        let _labelLeading = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100)
        _labelLeading.isActive = true
        labelLeading = _labelLeading
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            ])
    }
    
    open func setupGestureRecognizers() {
        let longG = UILongPressGestureRecognizer(target: self, action: #selector(longPressToShowMenu(_:)))
        addGestureRecognizer(longG)
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let node = node else { return }
        
        let height =  self.frame.height
        let eachW = eachWidth
        let indexLeading = eachW * CGFloat(node.currentDeep-1)
        horizonLine.frame = CGRect(x: indexLeading, y: height/2.0, width: 2*eachW, height: 1)
                
        let line1 = verticalLines[node.currentDeep-1]
        line1.isHidden = false
        line1.frame = CGRect(x: eachW * CGFloat(node.currentDeep-1), y: 0, width: 1, height: node.haveNext ? height : height*0.5);
        let line2 = verticalLines[node.currentDeep]
        line2.isHidden = false
        line2.frame = CGRect(x: eachW * CGFloat(node.currentDeep), y: height/2.0, width: 1, height: node.haveChild ? height/2.0 : 0);

        var parent = node.parent
        while parent != nil {
            guard let p = parent else { break }
            verticalLines[p.currentDeep-1].frame = CGRect(x: eachW*CGFloat(p.currentDeep-1), y: 0, width: 1, height: height)
            verticalLines[p.currentDeep-1].isHidden = !p.haveNext
            parent = p.parent
        }
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(copyText(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    open var menuItems: [UIMenuItem] {
        return [UIMenuItem(title: "Copy Node Info", action: #selector(copyText(_:)))]
    }
    
    @objc private func longPressToShowMenu(_ sender: UILongPressGestureRecognizer) {
        let menu = UIMenuController.shared
        if sender.state != .began, menu.isMenuVisible { return }
        
        menu.menuItems = menuItems
        menu.setTargetRect(label.bounds, in: self.label)
        menu.setMenuVisible(true, animated: true)
        becomeFirstResponder()
    }
    
    @objc private func copyText(_ sender: Any?) {
        UIPasteboard.general.string = node?.info.nodeDescription ?? node?.info.nodeTitle
    }
    
    @objc private func share(_ sender: Any?) {
        
        let activityVC = UIActivityViewController(activityItems: [node?.info.nodeTitle as Any, node?.info.nodeDescription as Any], applicationActivities: nil)
        
        listController?.present(activityVC, animated: true, completion: nil)
        
    }
    
    
}

fileprivate extension VerticalTreeIndexView {
    
    var eachWidth: CGFloat {
        guard let node = node else { return 0 }
        if case .eachLength(let lengthValue) = node.length {
            return lengthValue
        } else if case .indexLength(let lengthValue) = node.length {
            return lengthValue / CGFloat(max(node.treeDeep, 1))
        }
        return 0
    }
    
    var indexLeading: CGFloat {
        guard let node = node else { return 0 }
        let eachW = eachWidth
        let length = eachW * CGFloat(node.currentDeep-1);
        return length + 2*eachW
    }
}

extension Array {
    fileprivate mutating func flexibleReuse(targetCount: Int, map: () -> Element, handle: ((Element) -> Void)?) -> Void {
        if targetCount > count {
            let new = (0 ..< targetCount-count).map { _ in map() }
            self.append(contentsOf: new)
        } else if targetCount < count {
            let removeArr = self.prefix(count-targetCount)
            removeArr.forEach { handle?($0) }
            self.removeSubrange(0..<(count-targetCount))
        }
    }
}

extension UIColor {
    fileprivate static func treeDeep(_ nodeDeep: Int, _ treeDeep: Int) -> UIColor {
        let deepest: CGFloat = 0.8
        if nodeDeep >= treeDeep { return UIColor.black.withAlphaComponent(deepest) }
        return UIColor.black.withAlphaComponent(0.5 + (deepest-0.5)*CGFloat(nodeDeep)/CGFloat(treeDeep))
    }
}

#endif