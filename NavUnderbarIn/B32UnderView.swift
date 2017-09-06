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

            let topLabelInset: CGFloat = 10.0
            let bottomLabelInset: CGFloat = topLabelInset
            let leftLabelInset: CGFloat = 30.0
            let rightLabelInset: CGFloat = leftLabelInset
            
            _innerView.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = _innerView.topAnchor.constraint(equalTo: topAnchor, constant: topLabelInset)
            topConstraint.priority = 1
            topConstraint.isActive = true

            let bottomConstraint = _innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0*bottomLabelInset)
            bottomConstraint.isActive = true
            
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
    
    var underview: UIView {
        return _innerView
    }
    
    
    
}
