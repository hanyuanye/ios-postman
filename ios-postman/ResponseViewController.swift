//
//  ResponseViewController.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-02.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class ResponseViewController: UIViewController {
    private let responseText: NSAttributedString
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.responseText
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    init(responseText: NSAttributedString) {
        self.responseText = responseText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(responseLabel)
        
        responseLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
    }
}
