//
//  JSONKeyValueView.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-17.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import SnapKit

public enum BracketStyle {
    case array
    case dictionary
    
    var opening: String {
        switch self {
        case .array: return "["
        case .dictionary: return "{"
        }
    }
    
    var closing: String {
        switch self {
        case .array: return "]"
        case .dictionary: return "}"
        }
    }
    
    static func style(_ data: Any) -> BracketStyle {
        if data as? [Any] != nil {
            return .array
        }
        else {
            return .dictionary
        }
    }
}

class JSONKeyValueView: UIView {
    
    let fontSize: CGFloat = 18
    
    private lazy var keyLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: self.fontSize)
        label.textColor = .appJSONDefaultLabelColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
//        label.
        
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: self.fontSize)
        label.textColor = .appJSONDefaultLabelColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()
    
    private var contentView: UIView? = nil
    private var bottomView: UIView? = nil
    
    init(key: String, value: Bool) {
        super.init(frame: .zero)
        keyLabel.text = "\(key):"
        valueLabel.text = String(value)
        setupKeyValue()
    }

    init(key: String, value: Int) {
        super.init(frame: .zero)
        keyLabel.text = "\(key):"
        valueLabel.text = String(value)
        setupKeyValue()
    }
    
    init(key: String, value: String) {
        super.init(frame: .zero)
        keyLabel.text = "\(key):"
        valueLabel.text = "\"\(value)\""
        valueLabel.textColor = .appJSONStringLabelColor
        setupKeyValue()
    }
    
    init(key: String, view: UIView, bracketStyle: BracketStyle) {
        super.init(frame: .zero)
        keyLabel.text = key
        valueLabel.text = bracketStyle.opening
        valueLabel.textColor = .white
        
        let bottomView: UILabel = {
            let label = UILabel()
            
            label.text = bracketStyle.closing
            label.font = .systemFont(ofSize: self.fontSize)
            label.textColor = .white
            
            return label
        }()
        
        setupKeyValue(contentView: view, bottomView: bottomView)
    }
    
//    init(view: UIView, bracketStyle: BracketStyle) {
//        super.init(frame: .zearo)
//        keyLabel.text = bracketStyle.opening
//
//    }
    
    private func setupKeyValue() {
        addSubview(keyLabel)
        addSubview(valueLabel)
        
        keyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(keyLabel.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(self.snp.trailing)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupKeyValue(contentView: UIView, bottomView: UILabel) {
        let tapGestureRecognizer = UITapGestureRecognizer()
        keyLabel.addGestureRecognizer(tapGestureRecognizer)
        keyLabel.isUserInteractionEnabled = true
        tapGestureRecognizer.addTarget(self, action: #selector(onTap(_:)))
        self.contentView = contentView
        
        addSubview(keyLabel)
        addSubview(valueLabel)
        addSubview(contentView)
        addSubview(bottomView)
        
        keyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.centerY.equalTo(valueLabel.snp.centerY)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(keyLabel.snp.trailing).offset(15)
            make.trailing.lessThanOrEqualTo(self.snp.trailing)
            make.top.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(30)
            make.top.equalTo(keyLabel.snp.bottom).offset(5)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
        }
    }
    
    @objc func onTap(_ sender: Any) {
        guard let contentView = contentView else { return }
        contentView.isHidden = !contentView.isHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
