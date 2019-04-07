//
//  IndexTreeExtension.swift
//  VerticalTreeIndexView
//
//  Created by Daniel Yang on 2019/1/22.
//  Copyright © 2019 Daniel Yang. All rights reserved.
//

import UIKit
import ObjectiveC

private struct UIViewTreeAssociateKey {
    static var isFold = 0
}

extension NSObject: Infomation {
    fileprivate var isFold: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &UIViewTreeAssociateKey.isFold) as? NSNumber else {
                self.isFold = true
                return self.isFold
            }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(self, &UIViewTreeAssociateKey.isFold, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

final class NodeWrapper<Obj: NSObject & BaseTree>: TreeNode, Infomation where Obj.T == Obj {
    
    typealias U = NodeWrapper<Obj>
    var parent: U?
    var childs: [U]
    var index: Int
    var length: TreeNodeLength = .indexLength(80)
    var isFold: Bool
    var nodeTitle: String
    var info: Infomation { return self }
    var nodeDescription: String? { return obj?.nodeDescription }
    weak var obj: Obj?

    convenience init(obj: Obj) {
        self.init(obj)!
    }
    
    required init?(_ obj: Obj?) {
        guard let obj = obj else { return nil }
        self.obj = obj
        self.isFold = obj.isFold
        self.childs = obj.childs.map{ NodeWrapper(obj: $0) }
        self.index = obj.parent?.childs.firstIndex{ $0 == obj } ?? 0
        self.nodeTitle = obj.nodeTitle
        self.childs.forEach { $0.parent = self }
    }
}

final class ViewTreeNode: TreeNode, Infomation {
    
    typealias U = ViewTreeNode
    
    weak var view: UIView?
    var parent: ViewTreeNode?
    var childs: [ViewTreeNode]
    var isFold: Bool {
        get {
            return view?.isFold ?? true
        }
        set {
            view?.isFold = newValue
        }
    }
    var index: Int
    var length: TreeNodeLength
    var info: Infomation { return self }
    var nodeTitle: String
    var nodeDescription: String? {
        return view?.nodeDescription
    }

    convenience init(view: UIView) {
        self.init(view)!
    }
    
    required init?(_ view: UIView?) {
        guard let view = view else { return nil }
        self.view = view
        self.childs = view.subviews.compactMap{ ViewTreeNode($0) }
        self.index = view.superview?.subviews.firstIndex(of: view) ?? 0
        self.length = .indexLength(80)
        self.nodeTitle = view.nodeTitle
        
        self.childs.forEach { $0.parent = self }
    }
}
