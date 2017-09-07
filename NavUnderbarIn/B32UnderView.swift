//
//  B32UnderView.swift
//
//  Created by Vasiliy Fedotov on 12/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class B32UnderView: UIView {
    
    static let bottomLineHeight: CGFloat = 0.5

    private var _navigationBar: UINavigationBar!
    private var _lineView: UIView!
    private var _innerView: UIView!
    
    private var _customView: UIView?
    
    private let topLabelInset: CGFloat = 10.0
    private let bottomLabelInset: CGFloat = 10.0
    private let leftLabelInset: CGFloat = 30.0
    private let rightLabelInset: CGFloat = 30.0
    
    private var labelTopConstraint: NSLayoutConstraint?
    private var labelBottomConstraint: NSLayoutConstraint?
    
    init(withCustomView view: UIView?) {
        super.init(frame: CGRect.zero)
        
        _customView = view
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not realized")

        super.init(coder: aDecoder)
    }
    
    private func setup() {
        clipsToBounds = true
        
        _navigationBar = UINavigationBar()
        insertSubview(_navigationBar, at: 0)
        
        _navigationBar.translatesAutoresizingMaskIntoConstraints = false
        _navigationBar.heightAnchor.constraint(equalToConstant: 2000).isActive = true
        _navigationBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _navigationBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _navigationBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        
        if let innerView = _customView {
            _innerView = innerView
            addSubview(_innerView)

            _innerView.translatesAutoresizingMaskIntoConstraints = false
            
            
            let topConstraint = _innerView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            topConstraint.priority = 1
            topConstraint.isActive = true
            
            _innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-1.0*B32UnderView.bottomLineHeight)).isActive = true
            _innerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
            _innerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
            
        } else {
            _innerView = UILabel()
            addSubview(_innerView)

            _innerView.translatesAutoresizingMaskIntoConstraints = false
            
            labelTopConstraint = _innerView.topAnchor.constraint(equalTo: topAnchor, constant: topLabelInset)
            labelTopConstraint!.priority = 1
            labelTopConstraint!.isActive = true

            labelBottomConstraint = _innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0*bottomLabelInset)
            labelBottomConstraint!.isActive = true
            
            _innerView.leftAnchor.constraint(equalTo: leftAnchor, constant: leftLabelInset).isActive = true
            _innerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0*rightLabelInset).isActive = true
        }
        
        
        _lineView = UIView()
        _lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        addSubview(_lineView)
        
        _lineView.translatesAutoresizingMaskIntoConstraints = false
        _lineView.heightAnchor.constraint(equalToConstant: B32UnderView.bottomLineHeight).isActive = true
        _lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        _lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: B32UnderView.bottomLineHeight).isActive = true
    }
    
    var barTintColor: UIColor? {
        get {
            return _navigationBar.barTintColor
        }
        
        set {
            _navigationBar.barTintColor = newValue
        }
    }
    
    var isTranslucent: Bool {
        get {
            return _navigationBar.isTranslucent
        }
        
        set {
            _navigationBar.isTranslucent = newValue
        }
    }
    
    func setBarEqualentTo(_ bar: UINavigationBar) {
        
        _navigationBar.barTintColor = bar.barTintColor
        _navigationBar.isTranslucent = bar.isTranslucent
        _navigationBar.shadowImage = bar.shadowImage
        _navigationBar.setBackgroundImage(bar.backgroundImage(for: .default), for: .default)
        
//        _navigationBar. = bar.
    }
    
    var underview: UIView {
        return _innerView
    }

    var underLabel: UILabel? {
        return (_innerView as? UILabel)
    }
    
    var underLabelText: String? {
        set {
            underLabel?.text = newValue
            
            let textNotNull = !(newValue == nil)
            
            labelTopConstraint?.constant = textNotNull ? topLabelInset : 0.0
            labelBottomConstraint?.constant = textNotNull ? -1.0 * bottomLabelInset : 0.0
            underLabel?.superview?.layoutIfNeeded()
        }
        
        get {
            return underLabel?.text
        }
    }
    
    
}
