import RxCocoa
import RxSwift
import UIKit

class AppKeyValueView: UIView {
    lazy var keyTextField: AppTextField = {
        let textField = AppTextField()
        textField.placeholder = "Key"
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    lazy var valueTextField: AppTextField = {
        let textField = AppTextField()
        textField.placeholder = "Value"
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        
        return textField
    }()
    
    private lazy var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(keyTextField)
        contentView.addSubview(valueTextField)
        contentView.addSubview(seperatorView)
        
        keyTextField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(seperatorView.snp.top).offset(-5)
            make.trailing.lessThanOrEqualTo(valueTextField.snp.leading)
        }
        
        valueTextField.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(seperatorView.snp.top).offset(-5)
        }
        
        seperatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: AppKeyValueView {
    var keyValue: Observable<(String, String)> {
        Observable.combineLatest(
            base.keyTextField.rx.text.orEmpty,
            base.valueTextField.rx.text.orEmpty
        ) {($0, $1)}
    }
}
