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
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(responseLabel)
        
        navigationItem.title = "Response"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = backButton
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
        
        responseLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    @objc func close() {
        navigationController?.popViewController(animated: true)
    }
}
