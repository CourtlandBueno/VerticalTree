//
//  VerticalTreeProtocolExtension.swift
//  Pods-Demo
//
//  Created by Daniel Yang on 2019/4/30.
//

import Foundation

// MARK: - Infomation of NSObject
extension Infomation where Self: NSObjectProtocol {
    public var nodeTitle: String {
        return String(describing: type(of: self))
    }
    public var nodeDescription: String? {
        return String(describing: self.self)
    }
}

// MARK: - IndexPathNode
extension IndexPathNode {
    
    /// node of deep, value >= 1
    public var currentDeep: Int {
        return indexPath.count
    }
    
    public var index: Int {
        let index = indexPath
        return index[index.count-1]
    }
    
    public var haveChild: Bool {
        return !self.childs.isEmpty
    }
    
    public var haveParent: Bool {
        return self.parent != nil
    }
    
    public var haveNext: Bool {
        return self.index < (self.parent?.childs.count ?? 1) - 1
    }
}

extension IndexPathNode where Self.T == Self {
    
    public func getRootNode() -> T {
        let seq = sequence(first: self) { $0.parent }
        return seq.first(where: { $0.parent == nil })!
    }
    
    /// get allsubnodes by recurrence way
    ///
    /// - Parameter includeSelf: the allsubnodes include self or not
    /// - Returns: array of all subnodes
    public func allSubnodes(_ includeSelf: Bool = true) -> [T] {
        // good way but no suit, should in preorder traversal
        //        let seq = sequence(first: includeSelf ? [self] : self.childs) { $0.count<=0 ? nil : $0.map({ $0.childs }).flatMap({ $0 }) }
        //        return seq.flatMap{ $0 }
        var arr = self.childs.reduce([T]()) { $0 + [$1] + $1.allSubnodes(false) }
        if includeSelf { arr.insert(self, at: 0) }
        return arr
    }
    
    /// the deepest of node tree
    /// note: minimum deep start from 1
    public var treeDeep: Int {
        return getRootNode().allSubnodes().max { $0.currentDeep < $1.currentDeep }?.currentDeep ?? 1
    }
}

// MARK: - VerticalTreeNode

var VerticalTreeHeaderTitle: String {
    return "\n======>> Vertical Tree <<======\n\n"
}

// Pretty Print
extension VerticalTreeNode {
    /// Box-drawing character https://en.wikipedia.org/wiki/Box-drawing_character
    /// get treeNode pretty description
    public func nodePrettyText(_ moreInfoIfHave: Bool = false) -> String {
        let nodeChain = sequence(first: parent) { $0?.parent }
        let spaceStrings = nodeChain.map { ($0 != nil) ? ($0?.haveNext ?? false ? " │" : ($0?.haveParent ?? false ? "  ":"")) : "" }
        let isParent = haveChild
        let hasSibling = haveNext
        
        let firstPre = (haveParent ? (hasSibling ? " ├" : " └") : "") + (isParent ? "─┬─ ":"─── ")
        let initialPadding = spaceStrings.reversed().joined()
        var keyText: String = info.nodeTitle
        let keyPadding = initialPadding + firstPre

        if moreInfoIfHave {
            if let moreInfo = info.nodeDescription {
                var splitInfo = moreInfo.split(separator: .init("\n")).map({ String($0) })
                if !splitInfo.isEmpty {
                    splitInfo.insert(keyText, at: 0)
                }
                let lastPieceOfInfo = splitInfo.popLast()
                let nodeString = (hasSibling ? " │" : "  ") + (isParent ? " │  ": "   ")
                var joinedInfo = splitInfo.joined(separator: "\n" + initialPadding + nodeString)
                if let last = lastPieceOfInfo {
                    joinedInfo += "\n" + initialPadding + nodeString + last
                }
                if !joinedInfo.isEmpty {
                    keyText = joinedInfo
                }
            }
        }
        return keyPadding + keyText
    }
    
    /// as a subtree at current node
    public func subTreePrettyText(treeHeaderTitle: String? = nil, moreInfoIfHave: Bool = false, highlighted: Self? = nil) -> String {
        return (treeHeaderTitle ?? VerticalTreeHeaderTitle) + self.allSubnodes().map { $0.nodePrettyText(moreInfoIfHave) + "\n" }.joined()
    }
    
    /// found rootNode then get the full tree
    public func treePrettyText(treeHeaderTitle: String? = nil, _ moreInfoIfHave: Bool = false) -> String {
        return getRootNode().subTreePrettyText(treeHeaderTitle: treeHeaderTitle, moreInfoIfHave: moreInfoIfHave)
    }
}
