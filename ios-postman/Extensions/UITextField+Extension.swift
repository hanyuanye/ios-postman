//
//  UITextField+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-18.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UITextField {
    var editText: Observable<String> {
        self.controlEvent(.editingDidEnd).withLatestFrom(text.orEmpty).startWith("")
    }
}
