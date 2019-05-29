//
//  VerticalTreeCell.swift
//  Demo
//
//  Created by Daniel Yang on 2019/4/5.
//  Copyright © 2019 Daniel Yang. All rights reserved.
//
#if os(iOS)
import UIKit

open class VerticalTreeCell<T: VerticalTreeNode>: UITableViewCell {
    weak var listController: VerticalTreeListController<T>? {
        didSet {
            indexView.listController = listController
        }
    }
    open var descriptionHeightConstraint: NSLayoutConstraint?

    open lazy var indexView: VerticalTreeIndexView<T> = {
        let view = VerticalTreeIndexView<T>()
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open lazy var foldView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.darkText
        label.numberOfLines = 0
        return label
    }()

    open var fold: Bool = true {
        didSet {
            descriptionHeightConstraint?.isActive = fold
        }
    }
    
    open var node: T? {
        didSet {
            indexView.node = node
            descriptionLabel.text = node?.info.nodeDescription
            fold = node?.isFold ?? true
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContentView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentView()
    }
    
    open func setupContentView() {
        self.clipsToBounds = true
        
        contentView.addSubview(indexView)
        contentView.addSubview(foldView)
        foldView.addSubview(descriptionLabel)
        //        contentView.addSubview(descriptionLabel)
        
        let _descriptionHeightConstraint = descriptionLabel.heightAnchor.constraint(equalToConstant: 0)
        _descriptionHeightConstraint.priority = UILayoutPriority.required
        _descriptionHeightConstraint.isActive = fold
        descriptionHeightConstraint = _descriptionHeightConstraint
        
        let indexViewHeight = indexView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        indexViewHeight.priority = .defaultHigh
        indexViewHeight.isActive = true
        
        NSLayoutConstraint.activate([
            indexView.topAnchor.constraint(equalTo: contentView.topAnchor),
            indexView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            indexView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            //            indexView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            foldView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            foldView.topAnchor.constraint(greaterThanOrEqualTo: indexView.bottomAnchor),
            foldView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            foldView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: indexView.label.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: foldView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: foldView.bottomAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: foldView.trailingAnchor)
            ])
    }
}
#endif