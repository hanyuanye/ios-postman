import UIKit
import RxSwift

class AppKeyValuesStackView: UIView {
    
    let disposeBag = DisposeBag()
    
    let keyValuesBehavior = BehaviorSubject<[Parameter]>(value: [])
    let importKeyValuesPublisher = PublishSubject<[Parameter]>()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var addKeyValueButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appButtonColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    private lazy var addKeyValueButtonContentView: UIView = {
        let view = UIView()

        view.addSubview(self.addKeyValueButton)
        view.translatesAutoresizingMaskIntoConstraints = false

        self.addKeyValueButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }

        return view
    }()
    
    private lazy var contentStackView: UIView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.stackView,
            self.addKeyValueButtonContentView
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.setCustomSpacing(10, after: self.stackView)
        stackView.clipsToBounds = false
        
        return stackView
    }()
    
    init(addButtonTitle: String) {
        super.init(frame: .zero)
        
        addKeyValueButton.setTitle(addButtonTitle, for: .normal)
        
        addSubview(contentStackView)
        backgroundColor = .appDarkGray
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addKeyValueButton
            .rx
            .controlEvent(.touchUpInside)
            .flatMapLatest { [weak self] _ -> Observable<[Parameter]> in
            guard let self = self else { return .just([]) }
            
            let view = AppKeyValueView()
            view.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.addArrangedSubview(view)
    
            let keyValuesArray = self.stackView
                .arrangedSubviews
                .compactMap { $0 as? AppKeyValueView }
                .map { $0.rx.keyValue }
                
            return Observable.zip(keyValuesArray)
        }
        .bind(to: keyValuesBehavior)
        .disposed(by: disposeBag)
        
        importKeyValuesPublisher.bindOnMain(onNext: { [weak self] (parameters) -> Void in
            guard let self = self else { return }
            
            self.stackView
                .arrangedSubviews
                .compactMap { $0 as? AppKeyValueView }
                .forEach {
                    $0.removeFromSuperview()
                    self.stackView.removeArrangedSubview($0)
            }
            
            let views = parameters.map { parameter -> AppKeyValueView in
                let view = AppKeyValueView(parameter: parameter)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }
            
            views.forEach { self.stackView.addArrangedSubview($0) }
        })
        .disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension Reactive where Base: AppKeyValuesStackView {
    
    var keyValues: BehaviorSubject<[Parameter]> {
        base.keyValuesBehavior
    }
    
    var importKeyValuesPublisher: PublishSubject<[Parameter]> {
        base.importKeyValuesPublisher
    }
    
}
