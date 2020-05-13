//
//  JSONResponseView.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-17.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit

class JSONResponseView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: process(self.data))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let data: Any
    
    init(data: Any) {
        self.data = data
        
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func process(_ data: Any) -> [UIView] {
        if let arr = data as? [Any] {
            return process(arr)
        }
        else if let dict = data as? [String : Any] {
            return process(dict)
        }
        
        return []
    }
    
    func process(_ arr: [Any]) -> [UIView] {
        return arr.map { JSONResponseView(data: $0) }
    }
    
    func process(_ dict: [String : Any]) -> [UIView] {
        
        let views = dict.map { (key, value) -> UIView in
            if let bool = value as? Bool {
                return JSONKeyValueView(key: key, value: bool)
            }
            else if let int = value as? Int {
                return JSONKeyValueView(key: key, value: int)
            }
            else if let string = value as? String {
                return JSONKeyValueView(key: key, value: string)
            }
            else if let dict = value as? [String : Any] {
                let nestedResponseView = JSONResponseView(data: dict)
                return JSONKeyValueView(key: key, view: nestedResponseView, bracketStyle: .dictionary)
            }
            else if let arr = value as? [Any] {
                let nestedResponseView = JSONResponseView(data: arr)
                return JSONKeyValueView(key: key, view: nestedResponseView, bracketStyle: .array)
            }
            else {
                return JSONKeyValueView(key: key, value: "null")
            }
        }
        
        return views
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
